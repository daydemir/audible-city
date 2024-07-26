//
//  network.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
import NIOFoundationCompat
import NIOCore
import SotoDynamoDB

fileprivate let tenMB = 1024*1024*10

public protocol DynamoCodable: Codable {
    func writeable() throws -> [String: DynamoDB.AttributeValue]
}

public struct Database {
    static let dynamo = DynamoDB(client: awsClient)
    
    public static func batchWrite(toTable table: String, items: [DynamoCodable]) async throws {
        let putRequests = items.map { DynamoDB.WriteRequest.init(putRequest: .init(item: try! $0.writeable())) }
        
        do {
            let output = try await dynamo.batchWriteItem(DynamoDB.BatchWriteItemInput(requestItems: [table: putRequests]))
            print("output: \(output)")
        } catch {
            if (error as? SotoDynamoDB.DynamoDBErrorType)?.errorCode == "ProvisionedThroughputExceededException" {
                print("throughput exceeded, waiting 5 seconds...")
                try await Task.sleep(for: .seconds(5))
                try await batchWrite(toTable: table, items: items)
            } else {
                throw error
            }
        }
    }
}
