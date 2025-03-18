//
//  CocoaError+initWithErrno.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation



extension CocoaError {
	
	init (errno: Int32, operation:FileOperation = .read, userInfo: [String : Any]? = nil) {
		let cocoaErrorCode:Code
		switch errno {
		case ENOENT:
			cocoaErrorCode = .fileNoSuchFile
		
//		case EBADF:	//bad file descriptor?
		case EACCES:
			switch operation {
				case .read:
				cocoaErrorCode = .fileReadNoPermission	//read/write?
			case .write:
				cocoaErrorCode = .fileWriteNoPermission
			}
			
		case EEXIST:
			cocoaErrorCode = .fileWriteFileExists
			
//		case ENOTDIR:	//not a directory
//		case EISDIR:	//is a directory
			
		case EINVAL:
			//assumes invalid argument was file name
			cocoaErrorCode = .fileReadInvalidFileName
			
		case EFBIG:
			cocoaErrorCode = .fileReadTooLarge
			
		case ENOSPC:
			cocoaErrorCode = .fileWriteOutOfSpace
			
		case EROFS:
			cocoaErrorCode = .fileWriteVolumeReadOnly
			
		default:
			switch operation {
			case .read:
				cocoaErrorCode = .fileReadUnknown
			case .write:
				cocoaErrorCode = .fileWriteUnknown
			}
		}
		
		//NSURLErrorKey
		
		self = .init(cocoaErrorCode, userInfo: userInfo ?? [:])
	}
	
}


enum FileOperation {
	case read
	case write
}
