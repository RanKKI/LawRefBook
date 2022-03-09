# 用于给 law.json 增加 id

import json
from uuid import uuid4
import glob
import functools
import os
import re

def addUUID():
    with open("./law.json", "r") as f:
        data = json.load(f)
    for line in data:
        if "id" not in line:
            line["id"] = str(uuid4())
        for content in line["laws"]:
            if "id" not in content:
                content["id"] = str(uuid4())
    with open("./law.json", "w") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)


def getLevel(pattern):
    if "法" in pattern:
        return "法律"
    return "其他"

def addMissingLaw():
    with open("./law.json", "r") as f:
        data = json.load(f)

    def findTargetObj(pattern: str):
        for line in data:
            if line["category"] == pattern or (name in line and line["name"] == pattern):
                return line
        ret = dict()
        data.append(ret)
        return ret
    
    ignorePattern = ".+民法典|.+刑法"
    allLaws = set(map(lambda x: x["name"], functools.reduce(lambda a,b : a + b ,map(lambda x:x["laws"], data))))
    for line in glob.glob("./法律法规/**/*.md", recursive=True):
        if re.match(ignorePattern, line):
            # print(line)
            continue
        name = os.path.splitext(os.path.basename(line))[0]
        if name in allLaws:
            continue
        folder = line.split("/")[2]
        target = findTargetObj(folder)
        level = getLevel(folder)
        if "category" not in target:
            target["category"] = folder
        if "folder" not in target:
            target["folder"] = folder
        if "laws" not in target:
            target["laws"] = []
        item = dict()
        item["name"] = name
        item["level"] = level
        target["laws"].append(item)

    with open("./law.json", "w") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    

def main():
    addMissingLaw()
    addUUID()


if __name__ == "__main__":
    main()
