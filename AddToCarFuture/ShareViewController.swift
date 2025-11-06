import UIKit
import Social
import UniformTypeIdentifiers
import LinkPresentation
import OSLog
import CarFuturePackage

private let log = Logger(subsystem: "com.melvyn.carfuture.ShareExtension", category: "Share")

final class ShareViewController: SLComposeServiceViewController {
    private let allowedHosts: Set<String> = ["leboncoin.fr", "www.leboncoin.fr", "mobile.de", "www.mobile.de", "lacentrale.fr", "www.lacentrale.fr"]

    override func isContentValid() -> Bool { true }

    override func didSelectPost() {
        extractURL { [weak self] url in
            guard let self else { return }
            guard let url else {
                self.fail("Aucun lien détecté")
                return
            }

            let group = DispatchGroup()
            var metaTitle: String?
            var metaImageData: Data?
            var parsed: ParsedDetails = .init()

            group.enter()
            fetchLPMetadata(for: url) { title, imageData in
                metaTitle = title
                metaImageData = imageData
                group.leave()
            }

            group.enter()
            fetchHTML(url: url) { html in
                defer { group.leave() }
                guard let html else { return }
                let host = url.host ?? ""
                parsed = WebsiteParsers.parse(host: host, html: html)
            }

            group.notify(queue: .main) {
                var photos: [PhotoAssetCarFuture] = []
                if let metaImageData { photos = [PhotoAssetCarFuture(data: metaImageData)] }
                let preferredTitle = (metaTitle ?? parsed.title)?.trimmingCharacters(in: .whitespacesAndNewlines)
                let name = (preferredTitle?.isEmpty == false ? preferredTitle : nil) ?? url.lastPathComponent
                let isMoto = url.absoluteString.lowercased().contains("moto")
                let item = VehicleToBuy(
                    type: isMoto ? .motorcycle : .car,
                    name: name,
                    listingURL: url.absoluteString,
                    price: parsed.price,
                    photos: photos,
                    characteristics: Characteristics(
                        weightKg: parsed.weightKg,
                        seats: parsed.seats,
                        horsepower: parsed.horsepower,
                        torqueNm: parsed.torqueNm,
                        year: parsed.year
                    ),
                    plannedParts: []
                )
                SharedInbox.append(item)
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    override func configurationItems() -> [Any]! { [] }

    private func extractURL(completion: @escaping (URL?) -> Void) {
        if let items = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in items {
                if let attachments = item.attachments {
                    if let urlProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
                        urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (data, _) in
                            if let url = data as? URL {
                                DispatchQueue.main.async { completion(url) }
                            } else if let str = data as? String, let url = URL(string: str) {
                                DispatchQueue.main.async { completion(url) }
                            } else {
                                self.extractURLFromTextProviders(attachments: attachments, completion: completion)
                            }
                        }
                        return
                    }
                    self.extractURLFromTextProviders(attachments: attachments, completion: completion)
                    return
                }
            }
        }
        if let url = detectFirstURL(in: self.contentText) {
            completion(url)
            return
        }
        completion(nil)
    }

    private func extractURLFromTextProviders(attachments: [NSItemProvider], completion: @escaping (URL?) -> Void) {
        if let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            textProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (data, _) in
                var candidate: URL? = nil
                if let str = data as? String {
                    candidate = self.detectFirstURL(in: str)
                }
                DispatchQueue.main.async { completion(candidate) }
            }
        } else {
            let candidate = detectFirstURL(in: self.contentText)
            completion(candidate)
        }
    }

    private func detectFirstURL(in text: String?) -> URL? {
        guard let text, !text.isEmpty else { return nil }
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let match = detector?.firstMatch(in: text, options: [], range: range)
        if let m = match, let r = Range(m.range, in: text) {
            let urlStr = String(text[r]).trimmingCharacters(in: .whitespacesAndNewlines)
            let cleaned = urlStr.trimmingCharacters(in: CharacterSet(charactersIn: "()<>{}[].,;!?\n\r\t "))
            if let url = URL(string: cleaned) { return url }
        }
        return nil
    }

    private func fetchLPMetadata(for url: URL, completion: @escaping (_ title: String?, _ imageData: Data?) -> Void) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, _ in
            let title = metadata?.title
            let itemProvider = metadata?.imageProvider ?? metadata?.iconProvider
            guard let itemProvider else {
                DispatchQueue.main.async { completion(title, nil) }
                return
            }
            itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                let data: Data?
                if let image = object as? UIImage {
                    data = image.jpegData(compressionQuality: 0.9) ?? image.pngData()
                } else { data = nil }
                DispatchQueue.main.async { completion(title, data) }
            }
        }
    }

    private func fetchHTML(url: URL, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 7
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(html) }
        }.resume()
    }

    private func fail(_ message: String) {
        let err = NSError(domain: "ShareExt", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        extensionContext?.cancelRequest(withError: err)
    }
}
