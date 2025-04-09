import logo from "../../../../assets/logo.svg";
import styles from "./index.module.css";

export const Header = () => {
  return (
    <header data-testid="header" className={styles.header}>
      <img className={styles.img} src={logo} alt="Logo principal do sistema" />
    </header>
  );
};
