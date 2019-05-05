import Common
import Foundation

public struct SearchResponse: Decodable {
    public let matchedBy: String
    public let idSubMovieFile: String
    public let movieHash: String
    public let movieByteSize: String
    public let movieTimeMS: String
    public let idSubtitleFile: String
    public let subFileName: String
    public let subActualCD: String
    public let subSize: String
    public let subHash: String
    public let subLastTS: String
    public let subTSGroup: String?
    public let infoReleaseGroup: String?
    public let infoFormat: String?
    public let infoOther: String?
    public let idSubtitle: String
    public let userID: String
    public let subLanguageID: LanguageId
    public let subFormat: String
    public let subSumCD: String
    public let subAuthorComment: String
    public let subAddDate: String
    public let subBad: String
    public let subRating: String
    public let subSumVotes: String
    public let subDownloadsCnt: String
    public let movieReleaseName: String
    public let movieFPS: String
    public let idMovie: String
    public let idMovieImdb: String
    public let movieName: String
    public let movieNameEng: String?
    public let movieYear: String
    public let movieImdbRating: String?
    public let subFeatured: String
    public let userNickName: String?
    public let subTranslator: String
    public let iso639: String
    public let languageName: String
    public let subComments: String
    public let subHearingImpaired: String
    public let userRank: String?
    public let seriesSeason: String
    public let seriesEpisode: String
    public let movieKind: String
    public let subHD: String
    public let seriesIMDBParent: String
    public let subEncoding: String?
    public let subAutoTranslation: String
    public let subForeignPartsOnly: String
    public let subFromTrusted: String
    public let queryCached: Int?
    public let subTSGroupHash: String?
    public let subDownloadLink: URL
    public let zipDownloadLink: URL
    public let subtitlesLink: URL
    public let queryNumber: String
    public let score: Float

    enum CodingKeys: String, CodingKey {
        case matchedBy = "MatchedBy"
        case idSubMovieFile = "IDSubMovieFile"
        case movieHash = "MovieHash"
        case movieByteSize = "MovieByteSize"
        case movieTimeMS = "MovieTimeMS"
        case idSubtitleFile = "IDSubtitleFile"
        case subFileName = "SubFileName"
        case subActualCD = "SubActualCD"
        case subSize = "SubSize"
        case subHash = "SubHash"
        case subLastTS = "SubLastTS"
        case subTSGroup = "SubTSGroup"
        case infoReleaseGroup = "InfoReleaseGroup"
        case infoFormat = "InfoFormat"
        case infoOther = "InfoOther"
        case idSubtitle = "IDSubtitle"
        case userID = "UserID"
        case subLanguageID = "SubLanguageID"
        case subFormat = "SubFormat"
        case subSumCD = "SubSumCD"
        case subAuthorComment = "SubAuthorComment"
        case subAddDate = "SubAddDate"
        case subBad = "SubBad"
        case subRating = "SubRating"
        case subSumVotes = "SubSumVotes"
        case subDownloadsCnt = "SubDownloadsCnt"
        case movieReleaseName = "MovieReleaseName"
        case movieFPS = "MovieFPS"
        case idMovie = "IDMovie"
        case idMovieImdb = "IDMovieImdb"
        case movieName = "MovieName"
        case movieNameEng = "MovieNameEng"
        case movieYear = "MovieYear"
        case movieImdbRating = "MovieImdbRating"
        case subFeatured = "SubFeatured"
        case userNickName = "UserNickName"
        case subTranslator = "SubTranslator"
        case iso639 = "ISO639"
        case languageName = "LanguageName"
        case subComments = "SubComments"
        case subHearingImpaired = "SubHearingImpaired"
        case userRank = "UserRank"
        case seriesSeason = "SeriesSeason"
        case seriesEpisode = "SeriesEpisode"
        case movieKind = "MovieKind"
        case subHD = "SubHD"
        case seriesIMDBParent = "SeriesIMDBParent"
        case subEncoding = "SubEncoding"
        case subAutoTranslation = "SubAutoTranslation"
        case subForeignPartsOnly = "SubForeignPartsOnly"
        case subFromTrusted = "SubFromTrusted"
        case queryCached = "QueryCached"
        case subTSGroupHash = "SubTSGroupHash"
        case subDownloadLink = "SubDownloadLink"
        case zipDownloadLink = "ZipDownloadLink"
        case subtitlesLink = "SubtitlesLink"
        case queryNumber = "QueryNumber"
        case score = "Score"
    }
}

extension SearchResponse {
    public var formattedSeriesString: String? {
        guard !["", "0"].contains(seriesEpisode) && !["", "0"].contains(seriesSeason) else { return nil }
        return "S\(seriesSeason.leading(char: "0", toLength: 2))E\(seriesEpisode.leading(char: "0", toLength: 2))"
    }
}

extension Array where Element == SearchResponse {
    public func subtitle(at index: Int) -> Result<SearchResponse, ResultIndexOutOfBoundsError> {
        return self[safe: index].toResult(orError: ResultIndexOutOfBoundsError(index: index))
    }
}

extension String {
    func leading(char: Character, toLength: Int) -> String {
        let toAdd = toLength - count
        guard toAdd > 0 else { return self }
        return (Array(repeating: String(char), count: toAdd) + [self]).joined()
    }

    func trailing(char: Character, toLength: Int) -> String {
        let toAdd = toLength - count
        guard toAdd > 0 else { return self }
        return ([self] + Array(repeating: String(char), count: toAdd)).joined()
    }
}
