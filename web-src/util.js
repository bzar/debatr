export function findFirstIndex(predicate, arr) {
  for(var i = 0; i < arr.length; ++i) {
    if(predicate(arr[i])) {
      return i;
    }
  }
}
export function findFirst(predicate, arr) {
  for(var i = 0; i < arr.length; ++i) {
    if(predicate(arr[i])) {
      return arr[i];
    }
  }
}

export function titleCase(str) {
  if(!str || str.length === 0)
    return '';
  
  return str[0].toUpperCase() + str.slice(1);
}