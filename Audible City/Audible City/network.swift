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
import AWSDynamoDB
import SotoDynamoDB
import SotoS3

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

public struct Storage {
    static let s3 = S3(client: awsClient)
    
    public static func write(imageURL: String, bucket: String, key: String) async throws {
        let imageByteBuffer = try await HTTPClient.shared.execute(HTTPClientRequest(url: imageURL), timeout: .seconds(30)).body.collect(upTo: tenMB)
        let putRequest = S3.PutObjectRequest(body: .byteBuffer(imageByteBuffer), bucket: bucket, key: key)
        let output = try await s3.putObject(putRequest)
        print(output)
    }
}
