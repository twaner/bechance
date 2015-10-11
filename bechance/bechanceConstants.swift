//
//  bechanceConstants.swift
//  bechance
//
//  Created by Taiowa Waner on 8/2/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import Foundation
import UIKit

extension bechanceClient {
    
    
    struct JSONResponseKeys {
        
        // MARK: - Foursquare
        static let Id = "id"
        static let Name = "name"
        static let Twitter = "twitter"
        static let Title = "title"
        static let Facebook = "facebook"
        static let FacebookUsername = "facebookUsername"
        static let FacebookName = "facebookName"
        static let Location = "location"
        static let Lat = "lat"
        static let Lng = "lng"
        static let City = "city"
        static let State = "state"
        static let Meta = "meta"
        static let ErrorDetail = "errorDetail"
        static let ErrorType = "errorType"
        static let Venues = "venues"
        static let Response = "response"
    }
    
    struct Constants {
        // MARK: - Foursquare
        static let BaseFoursquareURL = "https://api.foursquare.com/v2/"
        static let VenueSearch = "venues/search?"
        static let Browse = "browse"
        static let FacebookPhotoURL = "https://graph.facebook.com/id/picture?type=large&return_ssl_resources=1"
        static let FacebookParameters = ["fields": "id, name, first_name, last_name, email, location, gender"]
        static let GraphPath = "me"
        
    }
    
    struct ParameterKeys {
        
        // MARK: - Foursquare Param Keys
        static let LL = "ll"
        static let Location = ""
        static let ProviderId = "providerId"
        static let Intent = "intent"
        static let OAuthToken = "oauth_token"
        static let ClientID = "client_id"
        static let ClientSecret = "client_secret"
        static let Version = "v"
        static let Query = "query"
    }
    
    struct UserKeys {
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let State = "state"
        static let City = "city"
        static let Email = "email"
        static let Gender = "gender"
        static let Image = "image"
        static let UserName = "user_name"
        static let Location = "location"
        static let ID = "id"
        static let Name = "name"
        static let UserNameUnder = "user_name"
        
    }
    
    // MARK: - Errors
    
    enum GenericErrors: ErrorType {
        case FailedToSaveToCoreData
        case FailedToSaveToParse
        case MissingData
    }
    
    enum PhotoSaveError: ErrorType {
        case EmptyPhoto
        case FailedToUpload
        case MissingData
        case FailedToSaveToCoreData
        case FailedToSaveToParse
    }
    
    enum LocationSaveError: ErrorType {
        case SaveError
        case FailedToSaveToCoreData
        case FailedToSaveToParse
        case MissingData
    }
}