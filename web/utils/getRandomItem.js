export function getRandomItem(obj) {
  // Get keys of the object
  const keys = Object.keys(obj);
  // Choose a random key
  const randomKey = keys[Math.floor(Math.random() * keys.length)];
  // Create and return the desired format
  return { name: randomKey, count: obj[randomKey] };
}
