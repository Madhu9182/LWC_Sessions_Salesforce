import addTodo from '@salesforce/apex/ToDoController.addTodo';
import getCurrentTodos from '@salesforce/apex/ToDoController.getCurrentTodos';
import { LightningElement, track } from 'lwc';


export default class ToDoManager extends LightningElement {

    // private properties are non-reactive in nature, which means they donot update template on their value change. use @track decorator to make a private property reactive.
    // All private properties are reactive, and we do not need to use @track decorator to make primitive properties reactive.
    // However, it is Recommended to use @track decorator for objects to listen for changes in the object.
    @track time = "8:15 PM";
    @track greeting = "Good Morning";

    @track toDos = [];

    // lifecycle methods are part of LWC framework and gets automatically invoked by the framework itself.
    connectedCallback(){
        // get current Time
        this.getTime();
        //fetch today's todos from server
        this.fetchTodos();

        // The "setInterval()" method repeatedly calls a function or executes a code snippet, with a fixed time delay between each call.
        // get time periodically after every minute
        setInterval( () => {
            this.getTime();
            console.log("set Interval called");
        },  
            1000*60);

    }
    /**
   * Get time and parse in human readable format
   * It follows 12 hour format
   */
    getTime(){
        const date = new Date();
        const hour = date.getHours();
        const min = date.getMinutes();

        // template literals are string literals allowing embedded expressions. you can multi-line strings and string interpolation features with them.
        this.time = `${this.getHour(hour)}:${this.getDoubleDigit(min)} ${this.getMidDay(hour)}`;
        this.setGreeting(hour);
    }
    //Convert 24 hours format to 12 hours format
    getHour(hour){
        return hour === 0 ? 12 : hour > 12 ? (hour)-12 : hour;
    }
    //return AM or PM based on current hour
    getMidDay(hour){
        return hour >= 12 ? "PM" : "AM";
    }
    //convert single digit to double digit
    getDoubleDigit(digit){
        return digit < 10 ? "0"+digit : digit;
    }

    // "this" keyword refers to class instance and you need to use it to modify class properties
    //return greeting based on current hour
    setGreeting(hour){
        if(hour < 12){
            this.greeting = "Good Morning";
        } else if(hour >= 12 && hour < 17){
            this.greeting = "Good Afternoon";
        } else {
            this.greeting = "Good Evening";
        }
    }
    /**
   * Add todos to backend
   * Get todo item based on input box value, and add to Salesforce object
   * Fetch fresh list of todos once inserted
   */
    addToDoHandler(){
        const inputBox = this.template.querySelector("lightning-input");
        console.log('current value : ', inputBox.value);

        // Instead of pushing a item value we are going to push javascript object
        const todo = {
            todoId : this.toDos.length,
            todoName : inputBox.value,
            done : false,
            todoDate : new Date()
        }

        // The Promise object represents the eventual completion (or failure) of an asynchronous operation, and its resulting value.
         //call addtodo server method to add new todo object
        //serialize todo object before sending to server
        addTodo({ payload: JSON.stringify(todo) }).then(result => {
            if (result) {
            //fetch fresh list of todos
            this.fetchTodos();
            }
        })
        .catch(error => {
            console.log("Error in inserting todo Item " + error);
        })
        // this.toDos.push(inputBox.value);
        this.toDos.push(todo);
        inputBox.value = "";
    }
    /**
   * Fetch todos from server
   * This method only retrives todos for today
   */
    fetchTodos(){
            getCurrentTodos().then(result => {
                if(result) {
                    // update todos property with result
                    this.toDos = result;
                }
            })
            .catch(error => {
                console.log("Error in fetching todo " + error);
            });
        }

    updateHandler(){
        this.fetchTodos();
    }

    deleteHandler(){
        this.fetchTodos();
    }

    // The "filter()" method creates a new array with all elements that pass the test implemented by the provided function.
    // get property to return upcoming/unfinished todos
    get upcomingTasks(){
        return this.toDos && this.toDos.length ? this.toDos.filter( todo => !todo.done) : [];
    }
    // get property to return completed todos
    get completedTasks(){
        return this.toDos && this.toDos.length ? this.toDos.filter( todo => todo.done) : [];
    }
}