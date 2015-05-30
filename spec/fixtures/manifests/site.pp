$realm = ''

class{'hadoop':
  realm => $realm,
}

class{'hive':
  realm => $realm,
}
