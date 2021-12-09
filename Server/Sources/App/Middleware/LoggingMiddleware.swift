//
//  LoggingMiddleware.swift
//  
//
//  Created by Charles Pisciotta on 12/8/21.
//

import Foundation
import Vapor
import VaporFirestore

struct LoggingMiddleware: AsyncMiddleware {

    let client: FirestoreResource

    init(app: Application) {
        self.client = app.firestoreService.firestore
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // TODO: Delete logs when a package is deleted
        let response = try await next.respond(to: request)

        // Confirm success before logging
        guard (response.status == HTTPResponseStatus.ok) || (response.status == HTTPResponseStatus.created) else {
            return response
        }

        // Log the status into the database
        do {
            let authPayload = try request.jwt.verify(as: AuthJWTPayload.self)
            let user = AuthenticationRequest.User(name: authPayload.username, isAdmin: authPayload.isAdmin)

            guard let packageMetadata = await getPackageMetadata(request: request, previousResponse: response) else {
                // If no package metadata, then we don't know what to log
                return response
            }

            guard let action = getActionForRequest(request: request) else {
                // If no action, then we don't know what to log
                return response
            }

            let packageHistoryItem = PackageHistoryItem(
                user: user,
                date: Date().ISO8601Format(),
                packageMetadata: packageMetadata,
                action: action
            )

            let _ : Firestore.Document<FirestorePackageHistoryItem> = try await client.createDocument(
                path: "requests",
                name: UUID().uuidString,
                fields: packageHistoryItem.asFirestoreHistoryItem()
            ).get()
        } catch {
            print(error)
            assertionFailure(error.localizedDescription)
        }

        return response
    }

    private func getPackageMetadata(request: Request, previousResponse: Response) async -> Metadata? {
        // Non-specific package routes don't have package logging
        guard let firstPath = request.route?.path.first?.description else { return nil }
        guard (firstPath != "authenticate") && (firstPath != "reset") && (firstPath != "packages") else { return nil }

        // Specific package version needs firstPath as "package"
        guard request.route?.path.first?.description == "package" else { return nil }

        let pathCount = request.route?.path.count

        // Package create or package ingestion
        if pathCount == 1, request.method == .POST {
            do {
                let payload = try request.content.decode(ProjectPackage.self)
                return payload.metadata
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }

        // Download package
        if pathCount == 2, request.method == .GET {
            do {
                let payload = try previousResponse.content.decode(ProjectPackage.self)
                return payload.metadata
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }

        // Update package
        if pathCount == 2, request.method == .PUT {
            do {
                let payload = try request.content.decode(ProjectPackage.self)
                return payload.metadata
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }

        // Delete package
        if pathCount == 2, request.method == .DELETE {
            do {
                guard let packageID = request.parameters.get("id") else {
                    assertionFailure("Expected package ID")
                    return nil
                }

                let doc: Firestore.Document<ProjectPackage> = try await client.getDocument(path: "package/\(packageID)", query: nil, mask: nil).get()
                return doc.fields?.metadata
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }

        // Rate package
        if pathCount == 3, request.route?.path.last?.description == "rate", request.method == .GET {
            do {
                guard let packageID = request.parameters.get("id") else {
                    assertionFailure("Expected package ID")
                    return nil
                }

                let doc: Firestore.Document<FirestoreProjectPackage> = try await client.getDocument(
                    path: "packages/\(packageID)",
                    query: nil,
                    mask: nil
                ).get()

                return doc.fields?.asProjectPackage().metadata
            } catch {
                print(error)
                assertionFailure(error.localizedDescription)
                return nil
            }
        }

        return nil
    }

    private func getActionForRequest(request: Request) -> PackageHistoryItem.Action? {
        // Non-specific package routes don't have an action
        guard let firstPath = request.route?.path.first?.description else { return nil }
        guard (firstPath != "authenticate") && (firstPath != "reset") && (firstPath != "packages") else { return nil }

        // Specific package version needs firstPath as "package"
        guard request.route?.path.first?.description == "package" else { return nil }

        let pathCount = request.route?.path.count

        // Package create or package ingestion
        if pathCount == 1, request.method == .POST {
            return .create
        }

        // Download package
        if pathCount == 2, request.method == .GET {
            return .download
        }

        // Update package
        if pathCount == 2, request.method == .PUT {
            return .update
        }

        // Delete package
        if pathCount == 2, request.method == .DELETE {
            return .delete
        }

        // Rate package
        if pathCount == 3, request.route?.path.last?.description == "rate", request.method == .GET {
            return .rate
        }

        return nil
    }

}
