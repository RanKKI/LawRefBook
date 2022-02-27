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
    var file: String?
    
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

let DeveloperMail = "rankki.dev@icloud.com"

var laws: [LawGroup] = [
    LawGroup(name: "宪法及相关法案", laws: [
        Law(name: "宪法"),
        Law(name: "国籍法"),
        Law(name: "身份证法"),
    ]),
    LawGroup(name: "民法", laws: [
        Law(name: "消费者权益保护法"),
        Law(name: "个人信息保护法"),
    ]),
    LawGroup(name: "行政法", laws: [
        Law(name: "食品安全法"),
    ]),
    LawGroup(name: "诉讼与非诉讼程序法", laws: [
        Law(name: "民事诉讼法"),
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
    LawGroup(name: "宪法修正案", laws: [
        Law(name: "宪法修正案（1988年）", folder:"宪法修正案", file: "1988年"),
        Law(name: "宪法修正案（1993年）", folder:"宪法修正案", file: "1993年"),
        Law(name: "宪法修正案（1999年）", folder:"宪法修正案", file: "1999年"),
        Law(name: "宪法修正案（2004年）", folder:"宪法修正案", file: "2004年"),
        Law(name: "宪法修正案（2018年）", folder:"宪法修正案", file: "2018年"),
    ]),
    LawGroup(name: "司法解释", laws: [
        Law(name: "最高人民法院关于适用《中华人民共和国民事诉讼法》的解释", folder: "司法解释", file: "民事诉讼法"),
    ]),
]
