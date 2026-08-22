//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI

@main
struct TaskBoardApp: App {
    
    // MARK: - Infrastructure Dependencies
    
    private let coreDataStack: CoreDataStackProtocol
    private let networkSessionFactory: NetworkSessionFactoryProtocol
    private let networkService: NetworkServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    // MARK: - Domain / Data Dependencies
    private let taskRepo: TaskRepositoryProtocol
    private let syncRepo: SyncMutationRepositoryProtocol
    private let syncEngine: SyncEngineProtocol
    
    init() {
        
        let dataStack = CoreDataStack()
        let sessionFactory = NetworkSessionFactory()
        let netService = NetworkService(sessionFactory: sessionFactory, baseURL: "https://api.example.com")
        
        self.coreDataStack = dataStack
        self.networkSessionFactory = sessionFactory
        self.networkService = netService
        self.networkMonitor = NetworkMonitor()
        let sRepo = SyncMutationRepository(coreDataStack: dataStack)
        let tRepo = TaskRepository(coreDataStack: dataStack, syncRepo: sRepo)
        self.taskRepo = tRepo
        self.syncRepo = sRepo
        self.syncEngine = SyncEngine(syncRepo: sRepo, taskRepo: tRepo, networkService: netService)
    }

    var body: some Scene {
        WindowGroup {
            BoardView(viewModel: BoardViewModel(taskRepo: taskRepo, syncEngine: syncEngine))
                .task {
                    await startNetworkMonitoring()
                }
        }
    }
    
    // MARK: - Background Processes
    
    private func startNetworkMonitoring() async {
        for await status in networkMonitor.statusStream {
            if status == .online {
                await syncEngine.startSync()
            }
        }
    }
}
