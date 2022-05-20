def infer_columns(args, source_columns) -> dict:
    for target_col, type in args['casts'].items():
        if 'overwrite_columns' in args and args['overwrite_columns']:
            source_columns[target_col.upper()] = type
        else:
            source_columns[f'{target_col.upper()}_{type.upper()}'] = type
    return source_columns
