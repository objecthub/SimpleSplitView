//
//  SplitEnums.swift
//  SplitView
//
//  Created by Steven Harris on 1/31/23.
//

import Foundation

/// The orientation of the `primary` and `secondary` views
public enum SplitLayout: String, CaseIterable {
  case horizontal
  case vertical
}

/// The two sides of a SplitView.
/// For `SplitLayout.horizontal`, `primary` is left, `secondary` is right.
/// For `SplitLayout.vertical`, `primary` is top, `secondary` is bottom.
public enum SplitSide: String {
  case primary
  case secondary
}
