import sys
import json
import ruamel.yaml

yaml = ruamel.yaml.YAML()
yaml.explicit_start = True

data = {}
with open(sys.argv[1]) as json_file:
    try:
        data = json.load(json_file, object_pairs_hook=ruamel.yaml.comments.CommentedMap)
    except json.decoder.JSONDecodeError:
        print("already converted")
        quit()

ruamel.yaml.scalarstring.walk_tree(data)  

with open(sys.argv[1], 'w') as yaml_file:
    yaml.dump(data, yaml_file)
