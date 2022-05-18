def infer_columns(args, source_columns) -> dict:
    source_columns[f"{args['column']}_encoded".upper()] = "integer"
    return source_columns
