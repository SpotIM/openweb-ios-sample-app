//
//  UIImage+URL.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 09/06/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

enum ImageError: Error {
    case failedToDownloadImage
}

extension UIImage {
    static func from(url: URL, completion: @escaping (Swift.Result<UIImage, ImageError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            // swiftlint:disable:next no_magic_numbers
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                  let data,
                  error == nil,
                  let image = UIImage(data: data) else {
                      DLog("Failed to download image from url: \(url))")
                      completion(.failure(ImageError.failedToDownloadImage))
                      return
                  }
            DispatchQueue.main.async { [image] in
                completion(.success(image))
            }
        }.resume()
    }
}
