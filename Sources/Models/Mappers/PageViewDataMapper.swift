import Foundation


enum PageViewDataMapper {
    
    static func map(_ entity: PageViewData) -> PageViewDataDTO {
        .init(url: entity.url, title: entity.title)
    }
}
