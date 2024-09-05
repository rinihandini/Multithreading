import Foundation
import CoreData
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example 1: Using GCD to Divide Tasks Across Threads

func exampleGCDDivideTasks() {
    let backgroundQueue = DispatchQueue.global(qos: .background)
    
    backgroundQueue.async {
        print("Background task started")
        sleep(2) // Simulate a network call or heavy computation
        print("Background task completed")
        
        // Switch back to the main thread to update the UI
        DispatchQueue.main.async {
            print("Updating UI on the main thread")
            PlaygroundPage.current.finishExecution()
        }
    }
}

// MARK: - Example 2: Using Dispatch Groups

func exampleDispatchGroups() {
    let dispatchGroup = DispatchGroup()
    let backgroundQueue = DispatchQueue.global(qos: .background)

    // Task 1
    dispatchGroup.enter()
    backgroundQueue.async {
        print("Task 1 started")
        sleep(2) // Simulate a network call or heavy computation
        print("Task 1 completed")
        dispatchGroup.leave()
    }

    // Task 2
    dispatchGroup.enter()
    backgroundQueue.async {
        print("Task 2 started")
        sleep(3) // Simulate another network call or computation
        print("Task 2 completed")
        dispatchGroup.leave()
    }

    // Notify when all tasks are completed
    dispatchGroup.notify(queue: DispatchQueue.main) {
        print("All tasks are completed.")
        PlaygroundPage.current.finishExecution()
    }
}

// MARK: - Example 3: Using Dispatch Semaphore

func exampleDispatchSemaphore() {
    let semaphore = DispatchSemaphore(value: 2) // Limit to 2 concurrent tasks
    let backgroundQueue = DispatchQueue.global(qos: .background)

    for i in 1...5 {
        backgroundQueue.async {
            semaphore.wait() // Wait for a free slot
            print("Task \(i) started")
            sleep(2) // Simulate a task duration
            print("Task \(i) completed")
            semaphore.signal() // Signal that a slot has been freed
        }
    }

    // Add a delay to give time for tasks to complete before ending the playground
    DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
        PlaygroundPage.current.finishExecution()
    }
}

// MARK: - Example 4: Using Core Data in a Multithreaded Environment

func exampleCoreDataMultithreading() {
    // Create an in-memory Core Data stack programmatically
    let managedObjectModel = NSManagedObjectModel()

    // Define the entity and attributes
    let entity = NSEntityDescription()
    entity.name = "YourEntity"
    entity.managedObjectClassName = NSManagedObject.self.description()
    
    // Create an attribute for the entity
    let attribute = NSAttributeDescription()
    attribute.name = "attribute"
    attribute.attributeType = .stringAttributeType
    entity.properties = [attribute]
    
    // Assign the entity to the model
    managedObjectModel.entities = [entity]
    
    // Create the persistent store coordinator and add an in-memory store
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        fatalError("Failed to add in-memory persistent store: \(error)")
    }
    
    // Create the managed object context
    let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    backgroundContext.persistentStoreCoordinator = persistentStoreCoordinator

    // Perform Core Data operations
    backgroundContext.perform {
        // Create a new entity object
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: "YourEntity", into: backgroundContext)
        newEntity.setValue("Example", forKey: "attribute")

        do {
            try backgroundContext.save()
            print("Saved in background context")
        } catch {
            print("Failed to save in background context: \(error)")
        }

        DispatchQueue.main.async {
            PlaygroundPage.current.finishExecution()
        }
    }
}

// Uncomment the function call you want to run:

exampleGCDDivideTasks()
// exampleDispatchGroups()
// exampleDispatchSemaphore()
// exampleCoreDataMultithreading()
