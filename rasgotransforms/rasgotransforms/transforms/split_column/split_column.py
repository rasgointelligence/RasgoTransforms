def infer_columns(args, source_columns) -> dict:
    for col in args['output_cols']:
        source_columns[col] = 'text'
    return source_columns
