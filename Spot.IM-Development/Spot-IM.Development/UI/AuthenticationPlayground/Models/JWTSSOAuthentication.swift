//
//  JWTSSOAuthentication.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct JWTSSOAuthentication {
    let domainName: String
    let spotId: String
    let JWTSecret: String
}

extension JWTSSOAuthentication {
    static let mockModels = [
        JWTSSOAuthentication(domainName: "Fox",
                             spotId: "sp_ANQXRpqH",
                             JWTSecret: "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5REEwNkVEMjAxOCIsInR5cCI6IkpXVCJ9.eyJwaWQiOiJ1cy1lYXN0LTE6ZDc1ODUxZmEtNWZhZi00OWIwLWFmODktYjAwZTYzNTFhMWMwIiwidWlkIjoiWkRjMU9EVXhabUV0TldaaFppMDBPV0l3TFdGbU9Ea3RZakF3WlRZek5URmhNV013Iiwic2lkIjoiZDJiNTE2ZGItMDBjYy00MTJhLWFmZmMtZTllMWFhYmI4NTAwIiwic2RjIjoidXMtZWFzdC0xIiwiYXR5cGUiOiJpZGVudGl0eSIsImR0eXBlIjoid2ViIiwidXR5cGUiOiJlbWFpbCIsImRpZCI6IiIsIm12cGRpZCI6IiIsInZlciI6MiwiZXhwIjoxNjMzNTk1MjMxLCJqdGkiOiIxYTQ5MjMyNi1hYzIyLTQ2MjItOGE1MS1mYTJjMjQwMjc5YjUiLCJpYXQiOjE2MDIwNTkyMzF9.BfBv3vGsj5Zd17nNDf1tetgUozIUvuBHj6ReBp-7TwJ3IFfbx7QSXiHVvKsnX_8DguH6uSdRQfjtUpteDRovvJ6Qq2uVUWUWd9XfD_QV6UsYhQph7Hfb5WzIVtEWf1Tu6Gm4RpgEGg37EnKSoDPeRkp9vBnj6fAGv2DKQUag3V-XbQJ7P98upfyMMkQY3e_COJF9HpDVdruJGB2iWu-pW81gjgzjGLupGSQKWp4bZz6dB9XvT06jgLY3IBMdZzRaWQfmBEsrHCNJZBgWyjjzs0PeZzRODOhUW3udoZSCXXsIZg7KKg_fOioEP9MG_QOoOZvElT9I3g1wtSKbX7so8g")
    ]
}
