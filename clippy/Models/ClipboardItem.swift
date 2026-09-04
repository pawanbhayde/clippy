import Foundation

// MARK: - Model representing a single clipboard history entry

/// Holds only metadata and on-disk paths — raw content and image bytes are
/// persisted separately (see Core/Storage) and never stored on this struct.
struct ClipboardItem: Codable, Identifiable, Equatable {
    var id: UUID
    var type: ClipboardType
    var createdAt: Date
    var lastUsedAt: Date
    var categoryIDs: [UUID]
    var isFavorite: Bool
    var contentHash: String
    var preview: String?
    var sourceApp: AppSource?
    var storagePath: String?
    var thumbnailPath: String?
    var fileSize: Int64?
    var isSensitive: Bool
    var isEncrypted: Bool

    init(
        id: UUID = UUID(),
        type: ClipboardType,
        createdAt: Date = Date(),
        lastUsedAt: Date = Date(),
        categoryIDs: [UUID] = [],
        isFavorite: Bool = false,
        contentHash: String,
        preview: String? = nil,
        sourceApp: AppSource? = nil,
        storagePath: String? = nil,
        thumbnailPath: String? = nil,
        fileSize: Int64? = nil,
        isSensitive: Bool = false,
        isEncrypted: Bool = false
    ) {
        self.id = id
        self.type = type
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.categoryIDs = categoryIDs
        self.isFavorite = isFavorite
        self.contentHash = contentHash
        self.preview = preview
        self.sourceApp = sourceApp
        self.storagePath = storagePath
        self.thumbnailPath = thumbnailPath
        self.fileSize = fileSize
        self.isSensitive = isSensitive
        self.isEncrypted = isEncrypted
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, createdAt, lastUsedAt, categoryIDs, isFavorite, contentHash, preview, sourceApp, storagePath, thumbnailPath, fileSize, isSensitive, isEncrypted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ClipboardType.self, forKey: .type)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastUsedAt = try container.decode(Date.self, forKey: .lastUsedAt)
        categoryIDs = try container.decodeIfPresent([UUID].self, forKey: .categoryIDs) ?? []
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        contentHash = try container.decode(String.self, forKey: .contentHash)
        preview = try container.decodeIfPresent(String.self, forKey: .preview)
        sourceApp = try container.decodeIfPresent(AppSource.self, forKey: .sourceApp)
        storagePath = try container.decodeIfPresent(String.self, forKey: .storagePath)
        thumbnailPath = try container.decodeIfPresent(String.self, forKey: .thumbnailPath)
        fileSize = try container.decodeIfPresent(Int64.self, forKey: .fileSize)
        isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        isEncrypted = try container.decodeIfPresent(Bool.self, forKey: .isEncrypted) ?? false
    }
}
