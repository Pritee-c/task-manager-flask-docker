const API_URL = 'http://localhost:5000/tasks';

async function fetchTasks() {
    const res = await fetch(API_URL);
    const tasks = await res.json();
    const list = document.getElementById('task-list');
    list.innerHTML = '';
    tasks.forEach(task => {
        const li = document.createElement('li');
        li.textContent = `${task.title}: ${task.description}`;
        if (task.completed) li.classList.add('completed');
        li.onclick = () => toggleComplete(task.id, !task.completed);
        const del = document.createElement('button');
        del.textContent = 'Delete';
        del.onclick = (e) => {
            e.stopPropagation();
            deleteTask(task.id);
        };
        li.appendChild(del);
        list.appendChild(li);
    });
}

async function addTask(title, description) {
    await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, description })
    });
    fetchTasks();
}

async function toggleComplete(id, completed) {
    await fetch(`${API_URL}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ completed })
    });
    fetchTasks();
}

async function deleteTask(id) {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
    fetchTasks();
}

document.getElementById('task-form').addEventListener('submit', e => {
    e.preventDefault();
    const title = document.getElementById('title').value;
    const description = document.getElementById('description').value;
    addTask(title, description);
    e.target.reset();
});

fetchTasks();
