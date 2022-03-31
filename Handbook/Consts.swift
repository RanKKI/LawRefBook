let LawLevel = [
    "宪法",
    "法律",
    "司法解释",
    "行政法规",
    "地方性法规",
    "经济特区法规",
    "自治条例",
    "单行条例",
    "案例",
    "其他",
]

enum LawGroupingMethod: String, CaseIterable {
    case department = "法律部门"
    case level = "法律阶位"
}

enum SearchType : String, CaseIterable {
    case catalogue = "目录"
    case fullText = "全文"
}
