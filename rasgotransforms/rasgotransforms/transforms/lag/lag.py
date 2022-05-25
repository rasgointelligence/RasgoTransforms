def infer_columns(args, source_columns) -> dict:
    for column in args['columns']:
        for amount in args['amounts']:
            source_columns[f"lag_{column}_{amount}".upper()] = source_columns[column.upper()]
    return source_columns
