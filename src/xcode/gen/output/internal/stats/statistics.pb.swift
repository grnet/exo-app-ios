// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/stats/statistics.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// This file is auto-generated, DO NOT make any changes here

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct SAP_Internal_Stats_Statistics {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The sequence in which cards are displayed
  /// remove a cardId here to hide a card from the app
  var cardIDSequence: [Int32] = []

  var keyFigureCards: [SAP_Internal_Stats_KeyFigureCard] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "SAP.internal.stats"

extension SAP_Internal_Stats_Statistics: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Statistics"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "cardIdSequence"),
    2: .same(proto: "keyFigureCards"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedInt32Field(value: &self.cardIDSequence) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.keyFigureCards) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.cardIDSequence.isEmpty {
      try visitor.visitPackedInt32Field(value: self.cardIDSequence, fieldNumber: 1)
    }
    if !self.keyFigureCards.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.keyFigureCards, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_Stats_Statistics, rhs: SAP_Internal_Stats_Statistics) -> Bool {
    if lhs.cardIDSequence != rhs.cardIDSequence {return false}
    if lhs.keyFigureCards != rhs.keyFigureCards {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
