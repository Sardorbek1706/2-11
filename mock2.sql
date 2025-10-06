import pool from "../config/database.js";
import { postValidation } from "../validations/post.validation.js";

async function getAll(req, res) {
    try {
        let { rows } = await pool.query(`
            SELECT 
                posts.title AS postTitle,
                posts.content AS postContent,
                posts.slug AS postSlug,
                users.first_name AS authorFirstName,
                users.last_name AS authorLastName,
                users.email AS authorEmail,
                COUNT(comments.id) AS commentsCount
            FROM posts
            INNER JOIN users ON posts.user_id = users.id
            LEFT JOIN comments ON comments.post_id = posts.id
            GROUP BY posts.id, users.first_name, users.last_name, users.email
        `)
        if (!rows.length) {
            return res.status(200).send({ message: "Not found!" })
        }
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

async function getPostsByUser(req, res) {
    try {
        let { user_id } = req.params
        let { rows } = await pool.query(`
            SELECT title, content, slug 
            FROM posts
            WHERE user_id = $1
        `, [user_id])
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

async function getOne(req, res) {
    try {
        let { id } = req.params
        let { rows } = await pool.query(`
            SELECT posts.*, users.first_name AS authorFirstName, users.last_name AS authorLastName, users.email AS authorEmail
            FROM posts
            INNER JOIN users ON posts.user_id = users.id
            WHERE posts.id = $1
        `, [id])
        if (!rows.length) {
            return res.status(200).send({ message: "Not found!" })
        }
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

async function create(req, res) {
    try {
        let { title, content, slug, user_id } = req.body
        let { error } = postValidation(req.body)
        if (error) {
            return res.status(400).send(error.details[0].message)
        }
        let { rows } = await pool.query(
            "INSERT INTO posts (title, content, slug, user_id) VALUES($1, $2, $3, $4) RETURNING *",
            [title, content, slug, user_id]
        )
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

async function update(req, res) {
    try {
        let { id } = req.params
        let data = req.body
        let keys = Object.keys(data)
        let values = Object.values(data)
        let query = keys.map((key, index) => key += ` =$${index + 1}`)
        let { rows } = await pool.query(`UPDATE posts SET ${query.join(',')} WHERE id=$${keys.length + 1} RETURNING *`, [...values, id])
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

async function remove(req, res) {
    try {
        let { id } = req.params
        let { rows } = await pool.query("DELETE FROM posts WHERE id=$1 RETURNING *", [id])
        res.status(200).send({ data: rows })
    } catch (error) {
        console.log(error.message)
    }
}

export { getAll, getOne, create, update, remove, getPostsByUser }
