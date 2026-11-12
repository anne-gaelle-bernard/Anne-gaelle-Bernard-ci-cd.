// Tests de l'algorithme de niveaux (algoniveau..js)

function setup(storage = {}) {
  jest.resetModules();
  localStorage.clear();
  for (const [key, value] of Object.entries(storage)) {
    localStorage.setItem(key, value);
  }
  document.body.innerHTML = `
    <div id="level"></div>
    <div id="counter"></div>
    <button id="bed"></button>
    <button id="resetButton"></button>`;
  require("../algoniveau..js");
}

const levelText = () => document.getElementById("level").textContent;
const counterText = () => document.getElementById("counter").textContent;
const click = (n = 1) => {
  for (let i = 0; i < n; i++) document.getElementById("bed").click();
};

describe("Algorithme XP / niveaux", () => {
  test("démarre au niveau 1 avec 0 XP", () => {
    setup();
    expect(levelText()).toBe("Niveau : 1");
    expect(counterText()).toBe("Nombre d'XP : 0");
  });

  test("un clic ajoute 1 XP et le sauvegarde", () => {
    setup();
    click();
    expect(counterText()).toBe("Nombre d'XP : 1");
    expect(localStorage.getItem("clickCount")).toBe("1");
  });

  test("le premier clic ne fait pas monter de niveau", () => {
    setup();
    click();
    expect(levelText()).toBe("Niveau : 1");
  });

  test("passe au niveau 2 en atteignant 100 XP", () => {
    setup();
    click(100);
    expect(levelText()).toBe("Niveau : 2");
  });

  test("restaure la progression depuis le localStorage", () => {
    setup({ clickCount: "250", levelValue: "3", clickValue: "3" });
    expect(levelText()).toBe("Niveau : 3");
    expect(counterText()).toBe("Nombre d'XP : 250");
  });

  test("le bouton reset remet tout à zéro", () => {
    setup();
    click(5);
    document.getElementById("resetButton").click();
    expect(counterText()).toBe("Nombre d'XP : 0");
    expect(levelText()).toBe("Niveau : 1");
    expect(localStorage.getItem("clickCount")).toBe("0");
  });
});
