//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Combine
@testable import RIBs
import XCTest

final class WorkerflowTests: XCTestCase {
    func test_nestedStepsDoNotRepeat() {
        var outerStep1RunCount = 0
        var outerStep2RunCount = 0
        var outerStep3RunCount = 0

        var innerStep1RunCount = 0
        var innerStep2RunCount = 0
        var innerStep3RunCount = 0

        let emptyPublisher = Just(((), ())).eraseToAnyPublisher()

        let workflow = Workflow<String>()
        _ = workflow
            .onStep { (_) -> AnyPublisher<((), ()), Never> in
                outerStep1RunCount += 1

                return emptyPublisher
            }
            .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                outerStep2RunCount += 1

                return emptyPublisher
            }
            .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                outerStep3RunCount += 1

                let innerStep: Step<String, Void, Void, Never>? = emptyPublisher.fork(workflow)

                innerStep?
                    .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                        innerStep1RunCount += 1
                        return emptyPublisher
                    }
                    .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                        innerStep2RunCount += 1
                        return emptyPublisher
                    }
                    .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                        innerStep3RunCount += 1
                        return emptyPublisher
                    }
                    .commit()

                return emptyPublisher
            }
            .commit()
            .sink("Test Actionable Item")

        XCTAssertEqual(outerStep1RunCount, 1, "Outer step 1 should not have been run more than once")
        XCTAssertEqual(outerStep2RunCount, 1, "Outer step 2 should not have been run more than once")
        XCTAssertEqual(outerStep3RunCount, 1, "Outer step 3 should not have been run more than once")

        XCTAssertEqual(innerStep1RunCount, 1, "Inner step 1 should not have been run more than once")
        XCTAssertEqual(innerStep2RunCount, 1, "Inner step 2 should not have been run more than once")
        XCTAssertEqual(innerStep3RunCount, 1, "Inner step 3 should not have been run more than once")
    }

    func test_workflowReceivesError() {
        let workflow = TestWorkflow()

        let emptyPublisher = Just(((), ())).eraseToAnyPublisher()
        _ = workflow
            .onStep { _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), WorkflowTestError> in
                Fail<(Void, Void), WorkflowTestError>(error: WorkflowTestError.error).eraseToAnyPublisher()
            }
            .onStep { _, _ -> AnyPublisher<((), ()), WorkflowTestError> in
                Just(((), ())).mapError().eraseToAnyPublisher()
            }
            .commit()
            .sink()

        XCTAssertEqual(0, workflow.completeCallCount)
        XCTAssertEqual(0, workflow.forkCallCount)
        XCTAssertEqual(1, workflow.errorCallCount)
    }

    func test_workflowDidComplete() {
        let workflow = TestWorkflow()

        let emptyPublisher = Just(((), ())).eraseToAnyPublisher()
        _ = workflow
            .onStep { _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .commit()
            .sink(())

        XCTAssertEqual(1, workflow.completeCallCount)
        XCTAssertEqual(0, workflow.forkCallCount)
        XCTAssertEqual(0, workflow.errorCallCount)
    }

    func test_workflowDidFork() {
        let workflow = TestWorkflow()

        let emptyPublisher = Just(((), ())).eraseToAnyPublisher()
        _ = workflow
            .onStep { _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                emptyPublisher
            }
            .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                let forkedStep: Step<Void, Void, Void, Never>? = emptyPublisher.fork(workflow)
                forkedStep?
                    .onStep { _, _ -> AnyPublisher<((), ()), Never> in
                        emptyPublisher
                    }
                    .commit()
                return emptyPublisher
            }
            .commit()
            .sink(())

        XCTAssertEqual(1, workflow.completeCallCount)
        XCTAssertEqual(1, workflow.forkCallCount)
        XCTAssertEqual(0, workflow.errorCallCount)
    }

    func test_fork_verifySingleInvocationAtRoot() {
        let workflow = TestWorkflow()

        var rootCallCount = 0
        let emptyPublisher = Just(((), ())).eraseToAnyPublisher()
        let rootStep = workflow
            .onStep { _ -> AnyPublisher<((), ()), Never> in
                rootCallCount += 1
                return emptyPublisher
            }

        let firstFork: Step<Void, Void, Void, Never>? = rootStep.eraseToAnyPublisher().fork(workflow)
        _ = firstFork?
            .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                Just(((), ())).eraseToAnyPublisher()
            }
            .commit()

        let secondFork: Step<Void, Void, Void, Never>? = rootStep.eraseToAnyPublisher().fork(workflow)
        _ = secondFork?
            .onStep { (_, _) -> AnyPublisher<((), ()), Never> in
                Just(((), ())).eraseToAnyPublisher()
            }
            .commit()

        XCTAssertEqual(0, rootCallCount)

        _ = workflow.sink(())

        XCTAssertEqual(1, rootCallCount)
    }
}

private enum WorkflowTestError: Error {
    case error
}

private class TestWorkflow: Workflow<Void> {
    var completeCallCount = 0
    var errorCallCount = 0
    var forkCallCount = 0

    override func didComplete() {
        completeCallCount += 1
    }

    override func didFork() {
        forkCallCount += 1
    }

    override func didReceiveError(_: Error) {
        errorCallCount += 1
    }
}
