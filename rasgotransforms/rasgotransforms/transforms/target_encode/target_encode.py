def infer_columns(args, source_columns) -> dict:
    source_columns[f"{args['column']}_target_encoded"] = 'float'
    return source_columns
