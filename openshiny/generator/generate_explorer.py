import pymustache
import os.path

config = """
{
    "entity" = "variable",
    "api_call" = "VariablesApi",
    "function_call" = "search_variables"
}
"""
with open(os.path.join(__file__, "template.mustache"),"r") as f:
    template = f.read()
