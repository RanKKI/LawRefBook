# 用于给 law.json 增加 id

import json
from uuid import uuid4


def main():
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


if __name__ == "__main__":
    main()
