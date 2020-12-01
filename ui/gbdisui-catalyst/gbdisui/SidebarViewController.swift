//
//  ViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 11/29/20.
//

import Combine
import UIKit

class SidebarViewController: UIViewController {

  private enum SidebarItemType: Int {
    case header, row, expandableRow
  }

  private enum SidebarSection: Int {
    case disassembled
  }

  private struct SidebarItem: Hashable, Identifiable {
    let id: UUID
    let type: SidebarItemType
    let title: String
    let subtitle: String?
    let image: UIImage?

    static func header(title: String, id: UUID = UUID()) -> Self {
      return SidebarItem(id: id, type: .header, title: title, subtitle: nil, image: nil)
    }

    static func expandableRow(title: String, subtitle: String?, image: UIImage?, id: UUID = UUID()) -> Self {
      return SidebarItem(id: id, type: .expandableRow, title: title, subtitle: subtitle, image: image)
    }

    static func row(title: String, subtitle: String?, image: UIImage?, id: UUID = UUID()) -> Self {
      return SidebarItem(id: id, type: .row, title: title, subtitle: subtitle, image: image)
    }
  }

  private struct RowIdentifier {
    static let allRecipes = UUID()
    static let favorites = UUID()
    static let recents = UUID()
  }

  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!

  private var disassembledSubscriber: AnyCancellable?

  override func viewDidLoad() {
    super.viewDidLoad()

    configureCollectionView()
    configureDataSource()
    applyInitialSnapshot()
  }
}

extension SidebarViewController {

  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    view.addSubview(collectionView)
  }

  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout() { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
      configuration.showsSeparators = false
      configuration.headerMode = .firstItemInSection
      let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      return section
    }
    return layout
  }
}

extension SidebarViewController: UICollectionViewDelegate {

}

extension SidebarViewController {

  private func configureDataSource() {
    let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
      (cell, indexPath, item) in

      var contentConfiguration = UIListContentConfiguration.sidebarHeader()
      contentConfiguration.text = item.title
      contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .subheadline)
      contentConfiguration.textProperties.color = .secondaryLabel

      cell.contentConfiguration = contentConfiguration
      cell.accessories = [.outlineDisclosure()]
    }

    let expandableRowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
      (cell, indexPath, item) in

      var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
      contentConfiguration.text = item.title
      contentConfiguration.secondaryText = item.subtitle
      contentConfiguration.image = item.image

      cell.contentConfiguration = contentConfiguration
      cell.accessories = [.outlineDisclosure()]
    }

    let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
      (cell, indexPath, item) in

      var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
      contentConfiguration.text = item.title
      contentConfiguration.secondaryText = item.subtitle
      contentConfiguration.image = item.image

      cell.contentConfiguration = contentConfiguration
    }

    dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
      (collectionView, indexPath, item) -> UICollectionViewCell in

      switch item.type {
      case .header:
        return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
      case .expandableRow:
        return collectionView.dequeueConfiguredReusableCell(using: expandableRowRegistration, for: indexPath, item: item)
      default:
        return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
      }
    }
  }

  private func disassembledSnapshot(files: [String] = []) -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
    var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
    let header = SidebarItem.header(title: "Disassembled")

    let items: [SidebarItem] = files.sorted().map {
      SidebarItem.row(title: $0, subtitle: nil, image: nil)
    }

    snapshot.append([header])
    snapshot.expand([header])
    snapshot.append(items, to: header)

    return snapshot
  }


  private func applyInitialSnapshot() {
    dataSource.apply(disassembledSnapshot(), to: .disassembled, animatingDifferences: false)
  }
}
