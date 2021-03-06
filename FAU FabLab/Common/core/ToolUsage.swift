import Foundation
import ObjectMapper

class ToolUsage : Mappable {
    
    private(set) var id             :Int64?
    private(set) var toolId         :Int64?
    private(set) var successorid    :Int64?
    private(set) var user           :String?
    private(set) var project        :String?
    private(set) var token          :String?
    private(set) var duration       :Int64?
    private(set) var startTime      :Int64?
    
    required init?(_ map: Map){}
    
    init(){}
    
    init(toolId: Int64, user: String, project: String, duration: Int64){
        self.toolId = toolId
        self.user = user
        self.project = project
        self.duration = duration
    }
    
    func mapping(map: Map) {
        id              <- (map["id"], Int64Transform())
        toolId          <- (map["toolId"], Int64Transform())
        successorid     <- (map["successorid"], Int64Transform())
        user            <-  map["user"]
        project         <-  map["project"]
        token           <-  map["token"]
        duration        <- (map["duration"], Int64Transform())
        startTime       <- (map["startTime"], Int64Transform())
    }
}
