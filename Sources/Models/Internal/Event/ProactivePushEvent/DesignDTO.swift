import Foundation


struct DesignDTO: Codable {
    
    let background: DesignBackgroundDTO

    let designBorder: DesignBorderDTO

    let designColor: DesignColorDTO

    let designCall2Action: DesignCall2ActionDTO
}
