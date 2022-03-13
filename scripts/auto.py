#!/usr/bin/env python3

# 用于给 law.json 增加 id

import json
from operator import truediv
from pickle import TRUE
from tkinter import Spinbox
from uuid import uuid4
import glob
import shutil
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
        item["name"] = name.replace("中华人民共和国", "")
        item["level"] = level
        target["laws"].append(item)

    with open("./law.json", "w") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

def renameFiles():
    for line in glob.glob("法律法规/**/*.md", recursive=True):
        newPath = line.replace("/中华人民共和国", "")
        shutil.move(line, newPath)

# 用于找到 “第x条" 或者 "第x条之一"
num = "[一二三四五六七八九十]"
title_re = "^(第"+num+"{1,6}?条(?:之"+num+"{1,2})*\s*)"

def cleanTitle(line: str):

    def f(matched):
        return matched.group(0).strip() + " "

    return re.sub(title_re, f, line)

def clean():
    for filename in glob.glob("法律法规/**/*.md", recursive=True):
        print(filename)
        with open(filename, "r") as f:
            data = f.readlines()
        flag = False
        for i, line in enumerate(data):
            if not line.strip():
                continue
            if line.startswith("#"):
                continue
            if line.startswith("<!-- INFO END -->"):
                flag = TRUE
                continue
            if not flag:
                continue

            line = cleanTitle(line)
            data[i] = line

            spliced = line.split(" ", 1)
            if len(spliced) == 2 and " " in spliced[1]:
                spliced[1] = spliced[1].replace(" ", "")
                data[i] = " ".join(spliced)
        with open(filename, "w") as f:
            f.writelines(data)

def test():
    assert "第一条 测试" == cleanTitle("第一条测试")
    assert "第一条 测试" == cleanTitle("第一条 测试")
    assert "第一二三四五条 测试" == cleanTitle("第一二三四五条测试")
    assert "第一条之一 测试" == cleanTitle("第一条之一测试")
    assert "第一条之一 测试" == cleanTitle("第一条之一 测试")

def main():
    test()
    renameFiles()
    addMissingLaw()
    addUUID()
    clean()

if __name__ == "__main__":
    main()
