def infer_columns(args, source_columns) -> dict:
    if 'names' in args and args['names']:
        for name in args['names']:
            source_columns[name] = 'double'
    else:
        for math_op in args['math_ops']:
            source_columns[math_op] = 'double'
    return source_columns
