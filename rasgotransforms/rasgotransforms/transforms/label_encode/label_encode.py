def infer_columns(args, source_columns) -> dict:
    source_columns[f"{args['column']}_encoded".upper()] = "int"
    source_columns["all_values_array"] = "array"
    return source_columns
