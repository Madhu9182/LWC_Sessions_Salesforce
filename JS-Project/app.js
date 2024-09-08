// //sets in javascript
// //They dont store duplicate values
// const students = new Set(["Madhu", "Pavan"]);
// console.log(students);

// students.add("Venkata");
// console.log(students);
// console.log(students.size);

// console.log(students.has("Madhu"));
// console.log(students.has("madhu"));

// students.delete("Madhu");
// console.log(students);

// // converting set to arrays
// const studentsArr = Array.from(students);
// console.log(studentsArr);

// students.clear();
// console.log(students);


// // Maps in Java Script
// // it stores a key and value pair where keys cannot be duplicate and values can be anything, it can be duplicate
const sections = new Map([["A2001", ["Madhu"]]]);
console.log(sections);

//to add the value in map you need to get the key first by using get method in Map
const students = sections.get("A2001");
students.push("Pavan");
console.log(sections);

//to add one more key in the Map using set
sections.set("B2001", ["Thor", "Tony Stark"])
console.log(sections);

// This will override the present key if we try to add the duplicate
//sections.set("A2001",[]);

console.log(sections.keys());
console.log(sections.values());
console.log(sections.entries());

console.log(sections.has("A2001"));

console.log(!sections.has("A2001") && sections.set("A2001"));
console.log(sections);