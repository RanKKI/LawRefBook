//
//  Config.swift
//  law.handbook
//
//  Created by Hugh Liu on 25/2/2022.
//

import Foundation

struct Law: Hashable {
    var name: String
    var folder: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}

struct LawGroup : Hashable{
    var name: String
    var laws: [Law]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}


var laws: [LawGroup] = [
    LawGroup(name: "宪法及相关法案", laws: [
        Law(name: "宪法"),
        Law(name: "国籍法"),
        Law(name: "身份证法"),
    ]),
    LawGroup(name: "宪法修正案", laws: [
        Law(name: "1988年", folder:"宪法修正案"),
        Law(name: "1993年", folder:"宪法修正案"),
        Law(name: "1999年", folder:"宪法修正案"),
        Law(name: "2004年", folder:"宪法修正案"),
        Law(name: "2018年", folder:"宪法修正案"),
    ]),
    LawGroup(name: "民法典", laws: [
        Law(name: "总则", folder: "民法典"),
        Law(name: "物权", folder: "民法典"),
        Law(name: "合同", folder: "民法典"),
        Law(name: "人格权", folder: "民法典"),
        Law(name: "婚姻家庭", folder: "民法典"),
        Law(name: "继承", folder: "民法典"),
        Law(name: "侵权责任", folder: "民法典"),
        Law(name: "附则", folder: "民法典"),
    ]),
    LawGroup(name: "民法", laws: [
        Law(name: "消费者权益保护法"),
    ]),
]
