def infer_columns(args, source_columns) -> dict:
    for col1 in args['columns1']:
        for col2 in args['columns2']:
            source_columns[f"{col1}_{col2}_Distance"] = 'int'
    return source_columns
