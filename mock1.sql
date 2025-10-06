import pool from "../config/database.js";
import { postValidation } from "../validations/post.validation.js";
async function getAll(req, res) {
  try {
    const { rows } = await pool.query(`
      SELECT 
        posts.id,
        posts.title,
        posts.content,
        posts.slug,
        users.first_name AS author_first_name,
        users.last_name AS author_last_name,
        users.email AS author_email,
        COUNT(comments.id) AS comments_count
      FROM posts
      INNER JOIN users ON posts.user_id = users.id
      LEFT JOIN comments ON comments.post_id = posts.id
      GROUP BY posts.id, users.first_name, users.last_name, users.email
      ORDER BY posts.id DESC
    `);

    if (!rows.length) {
      return res.status(404).send({ message: "No posts found" });
    }

    res.status(200).send({ data: rows });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}
async function getOne(req, res) {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      `
      SELECT 
        posts.*, 
        users.first_name AS author_first_name,
        users.last_name AS author_last_name,
        users.email AS author_email
      FROM posts
      INNER JOIN users ON posts.user_id = users.id
      WHERE posts.id = $1
    `,
      [id]
    );

    if (!rows.length) {
      return res.status(404).send({ message: "Post not found" });
    }

    res.status(200).send({ data: rows[0] });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}
async function create(req, res) {
  try {
    const { title, content, slug, user_id } = req.body;
    const { error } = postValidation(req.body);
    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const { rows } = await pool.query(
      `
      INSERT INTO posts (title, content, slug, user_id)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `,
      [title, content, slug, user_id]
    );

    res.status(201).send({ data: rows[0] });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}

async function update(req, res) {
  try {
    const { id } = req.params;
    const data = req.body;

    const keys = Object.keys(data);
    const values = Object.values(data);

    if (keys.length === 0) {
      return res.status(400).send({ message: "No data provided" });
    }

    const query = keys.map((key, i) => `${key}=$${i + 1}`);
    const { rows } = await pool.query(
      `UPDATE posts SET ${query.join(", ")} WHERE id=$${keys.length + 1} RETURNING *`,
      [...values, id]
    );

    if (!rows.length) {
      return res.status(404).send({ message: "Post not found" });
    }

    res.status(200).send({ data: rows[0] });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}

async function remove(req, res) {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      "DELETE FROM posts WHERE id=$1 RETURNING *",
      [id]
    );

    if (!rows.length) {
      return res.status(404).send({ message: "Post not found" });
    }

    res.status(200).send({ data: rows[0] });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}

// 📍 Muallifning barcha postlarini olish
async function getPostsByUser(req, res) {
  try {
    const { user_id } = req.params;
    const { rows } = await pool.query(
      `
      SELECT id, title, content, slug 
      FROM posts
      WHERE user_id = $1
      ORDER BY id DESC
    `,
      [user_id]
    );

    res.status(200).send({ data: rows });
  } catch (error) {
    console.log(error.message);
    res.status(500).send({ error: error.message });
  }
}

export { getAll, getOne, create, update, remove, getPostsByUser };
