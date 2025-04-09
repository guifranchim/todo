import { Link } from "react-router-dom";
import Capa from "../../assets/capa.svg";
import styles from "./index.module.css";

function LandingPage() {
  return (
    <section className={styles.container}>
      <article className={styles.title_container}>
        <h1>To do List</h1>
        <h2>Desafio do Ignite</h2>
      </article>
      <article>
        <Link to="/to-do">
          <img src={Capa} alt="Capa do sistema" />
        </Link>
      </article>
    </section>
  );
}

export default LandingPage;
