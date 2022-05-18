def infer_columns(args, source_columns) -> dict:
    source_columns[f"{args['column']}_target_encoded"] = 'decimal'
    return source_columns
