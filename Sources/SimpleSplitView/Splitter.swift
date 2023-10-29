//
//  Splitter.swift
//  SplitView
//
//  Created by Steven Harris on 8/18/21.
//

import SwiftUI

/// Custom splitters must conform to SplitDivider, just like the default `Splitter`.
public protocol SplitDivider: View {
  var styling: SplitStyling { get }
}

/// The Splitter that separates the `primary` from `secondary` views in a `Split` view.
/// The Splitter holds onto `styling`, which is accessed by Split to determine the
/// `visibleThickness` by which the `primary` and `secondary` views are separated. The
/// `styling` also publishes `previewHide`, which specifies whether we are previewing
/// what Split will look like when we hide a side. The Splitter uses `previewHide`
/// to change its `dividerColor` to `.clear` when being previewed, while Split uses it
/// to determine whether the spacing between views should be `visibleThickness` or zero.
public struct Splitter: SplitDivider {
  
  @Binding private var layout: SplitLayout
  
  @ObservedObject public var styling: SplitStyling
  
  // Changes based on styling.previewHide
  @State private var dividerColor: Color
  
  private let privateColor: Color?
  private let privateInset: CGFloat?
  private let privateVisibleThickness: CGFloat?
  private let privateInvisibleThickness: CGFloat?
  
  private var color: Color {
    privateColor ?? styling.color
  }
  
  private var inset: CGFloat {
    privateInset ?? styling.inset
  }
  
  private var visibleThickness: CGFloat {
    privateVisibleThickness ?? styling.visibleThickness
  }
  
  private var invisibleThickness: CGFloat {
    privateInvisibleThickness ?? styling.invisibleThickness
  }
  
  // Defaults
  public static var defaultColor: Color = Color.gray
  public static var defaultInset: CGFloat = 6
  public static var defaultVisibleThickness: CGFloat = 4
  public static var defaultInvisibleThickness: CGFloat = 30

  public var body: some View {
    ZStack {
      switch self.layout {
        case .horizontal:
          Color.clear
            .frame(width: self.invisibleThickness)
            .padding(0)
          RoundedRectangle(cornerRadius: self.visibleThickness / 2)
            .fill(self.dividerColor)
            .frame(width: self.visibleThickness)
            .padding(EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0))
        case .vertical:
          Color.clear
            .frame(height: invisibleThickness)
            .padding(0)
          RoundedRectangle(cornerRadius: visibleThickness / 2)
            .fill(dividerColor)
            .frame(height: visibleThickness)
            .padding(EdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset))
      }
    }
    .contentShape(Rectangle())
    // Otherwise, styling.color does not appear at open. If we are previewing hiding a
    // side using drag-to-hide, then we make the color .clear.
    .task { dividerColor = color }
    .onChange(of: styling.previewHide) { hide in
      self.dividerColor = hide ? .clear : privateColor ?? color
    }
    // Perhaps should consider some kind of custom hoverEffect, since the cursor change
    // on hover doesn't work on iOS.
    .onHover { inside in
      #if targetEnvironment(macCatalyst) || os(macOS)
      // With nested split views, it's possible to transition from one Splitter to another,
      // so we always need to pop the current cursor (a no-op when it's the only one). We
      // may or may not push the hover cursor depending on whether it's inside or not.
      NSCursor.pop()
      if inside {
        self.layout == .horizontal ? NSCursor.resizeLeftRight.push()
                                   : NSCursor.resizeUpDown.push()
      }
      #endif
    }
  }
  
  public init(layout: Binding<SplitLayout>,
              color: Color? = nil,
              inset: CGFloat? = nil,
              visibleThickness: CGFloat? = nil,
              invisibleThickness: CGFloat? = nil) {
    self._layout = layout
    self.privateColor = color
    self.privateInset = inset
    self.privateVisibleThickness = visibleThickness
    self.privateInvisibleThickness = invisibleThickness
    self.styling = SplitStyling(color: color,
                                inset: inset,
                                visibleThickness: visibleThickness,
                                invisibleThickness: invisibleThickness)
    self._dividerColor = State(initialValue: color ?? Self.defaultColor)
  }
  
  public init(layout: Binding<SplitLayout>, styling: SplitStyling) {
    self._layout = layout
    self.privateColor = styling.color
    self.privateInset = styling.inset
    self.privateVisibleThickness = styling.visibleThickness
    self.privateInvisibleThickness = styling.invisibleThickness
    self.styling = styling
    self._dividerColor = State(initialValue: styling.color)
  }
  
  /// A Splitter (that responds to changes in layout) that is a line across the full
  /// breadth of the view, by default gray and visibleThickness of 1
  public static func line(layout: Binding<SplitLayout>,
                          color: Color? = nil,
                          visibleThickness: CGFloat? = nil) -> Splitter {
    return Splitter(layout: layout,
                    color: color,
                    inset: 0,
                    visibleThickness: visibleThickness ?? 1)
  }
    
  /// An invisible Splitter (that responds to changes in layout) that is a line across
  /// the full breadth of the view
  public static func invisible(layout: Binding<SplitLayout>) -> Splitter {
    return Splitter.line(layout: layout, visibleThickness: 0)
  }
}

struct Splitter_Previews: PreviewProvider {
  static var previews: some View {
    Splitter(layout: .constant(.horizontal))
    Splitter(layout: .constant(.horizontal),
             color: Color.red,
             inset: 2,
             visibleThickness: 8,
             invisibleThickness: 30)
    Splitter.line(layout: .constant(.horizontal))
    Splitter(layout: .constant(.vertical))
    Splitter(layout: .constant(.vertical),
             color: Color.red,
             inset: 2,
             visibleThickness: 8,
             invisibleThickness: 30)
    Splitter.line(layout: .constant(.vertical))
  }
}
