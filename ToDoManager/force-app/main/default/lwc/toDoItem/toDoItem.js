import deleteTodo from '@salesforce/apex/ToDoController.deleteTodo';
import updateTodo from '@salesforce/apex/ToDoController.updateTodo';
import { LightningElement, api } from 'lwc';


export default class ToDoItem extends LightningElement {

    // public properties are reactive. if the value of a public property changes, the component rerenders. To expose a public property, decorate a field with @api
    @api todoId;
    @api todoName;
    @api done = false;

    updateHandler(){
        const todo = {
            todoId : this.todoId,
            todoName : this.todoName,
            done : !this.done
        }

        updateTodo({ payload : JSON.stringify(todo)})
            .then(result => {
                console.log('Item is updated successfully');
                // Events can be to communicate from the child component to the parent component. you can also pass the payload/data along with the event
                const updateEvent = new CustomEvent('update');
                this.dispatchEvent(updateEvent); // we are firing these events from child components but our parent component should listen to these events as well
            })
            .catch(error => {
                console.error('Error in update' , error);
            });
    }

    deleteHandler(){
        deleteTodo({todoId : this.todoId})
            .then(result => {
                console.log("Item deleted successfully");
                const deleteEvent = CustomEvent('delete');
                this.dispatchEvent(deleteEvent); // we are firing these events from child components but our parent component should listen to these events as well
            })
            .catch(error => {
                console.error('Error in delete ', error);
            });
    }

    get containerClass(){
        return this.done ? "todo completed" : "todo upcoming";
    }

    get iconName(){
        return this.done ? "utility:check" : "utility:add";
    }
}