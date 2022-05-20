def infer_columns(args, source_columns) -> dict:
    if 'alias' in args and args['alias']:
        source_columns[args['alias']] = 'varchar'
    else:
        source_columns[f"REPLACE_{args['source_col']}"] = 'text'
    return source_columns
