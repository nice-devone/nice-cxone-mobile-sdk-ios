import Foundation


enum PageViewDataMapper {
    
    static func map(_ entity: PageViewData) -> PageViewDataDTO {
        PageViewDataDTO(url: entity.url, title: entity.title)
    }
}
