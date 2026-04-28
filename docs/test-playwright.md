# Patterns de tests UI

## User Facing Attributes

**Ce pattern propose d’utiliser des sélecteurs basés sur des attributs ou propriétés visibles par l’utilisateur·ice** (rôles accessibles, labels, textes, etc.) pour identifier et interagir avec les éléments de l'interface. Cela permet de rendre les tests plus intuitifs et orientés vers l'expérience réelle de l'utilisateur·ice, en étant moins dépendants de CSS, tout en favorisant des pratiques de développement prenant en compte l’accessibilité.

>💡 C’est aujourd’hui l’approche préconisée par la majorité des outils d’automatisation de navigateur comme Playwright.  
> Si vous utilisez Cypress, bien que la documentation évoque Testing Library, elle préconise l’utilisation de data-test-id.  
> Mais nous ne sommes pas d’accord avec cette recommandation :D.  
> Dans la même idée, utiliser des locators basés sur le CSS ou le XPath ne sont pas recommandés, car le DOM peut souvent changer, ce qui conduit à des tests non résilients.

### Exemples de code pour accéder aux éléments du DOM d’une page web

#### Exemple d’utilisation avec Testing Library

```typescript
// tests/homepage.spec.ts
import { describe, it, expect } from 'vitest';
import { screen } from '@testing-library/dom';

describe('HomePage - User Facing Attributes', () => {
  it('devrait afficher un titre contenant "Playwright" et un lien "Get started" visible', async () => {
    await this.page.goto('https://playwright.dev/');

    // Sélection basée sur des attributs exposés à l'utilisateur·ice
    const header = screen.getByRole('heading', { level: 1, name: /Playwright/i });
    expect(header).toBeInTheDocument();

    const getStartedLink = screen.getByRole('link', { name: /Get started/i });
    expect(getStartedLink).toBeVisible();
  });
});
```

#### Exemple d’utilisation avec Playwright

```typescript
// tests/homepage.spec.ts
import { test, expect, Page, Locator } from '@playwright/test';
import { PlaywrightHomePage } from '../pages/PlaywrightHomePage';

test.describe('Test du site Playwright via User Facing Attributes', () => {
  test('Vérifier que le titre principal contient "Playwright" et que le lien "Get started" est visible', async ({ page }) => {
    await this.page.goto('https://playwright.dev/');

    // Sélection basée sur des attributs exposés à l'utilisateur·ice
    const header = this.page.getByRole('heading', { level: 1 });
    const getStartedLink = this.page.getByRole('link', { name: /Get started/i });

    await expect(header).toContainText('Playwright');
    await expect(getStartedLink).toBeVisible();
  });
});
```

### Avantages

- **Robustesse des tests** :  
Les tests sont moins susceptibles de casser lors de modifications techniques (comme des changements d'attributs CSS ou ordre des balises dans le DOM).
- **Alignement avec l'UX** :  
Les sélecteurs utilisés correspondent à ce que voit et utilise réellement l'utilisateur·ice, améliorant ainsi la pertinence des tests.
- **Promotion des bonnes pratiques d'accessibilité** :  
Toutes les interfaces ne sont pas toujours dotées d'attributs ou de rôles pertinents, ce pattern incite donc développer des interfaces accessibles et bien structurées.
- **Lisibilité et clarté** :  
Les tests sont plus explicites, car ils décrivent les éléments de l'interface tels qu'une personne les perçoit.

### Inconvénients
- **Dépendance au contenu textuel** :  
Les tests peuvent devenir fragiles si les libellés ou textes changent fréquemment, même si la fonctionnalité reste correcte.
- **Moins de contrôle sur des sélecteurs complexes** :
Pour certaines interactions spécifiques ou des éléments très dynamiques (comme un élément dans un tableau ou une liste de données), il peut être nécessaire d'utiliser des sélecteurs techniques en complément ou remplacement.

## Page Object Model
Son objectif principal est de **séparer la logique de test** (les scénarios et assertions) de la **logique d'interaction avec l'interface**.

### Exemples de code avec Playwright

```typescript
// pages/PlaywrightHomePage.ts
import { Page, Locator } from '@playwright/test';

export class PlaywrightHomePage {
  readonly page: Page;
  readonly header: Locator;

  constructor(page: Page) {
    this.page = page;
    // On cible ici le titre principal de la page (par exemple, l'élément h1)
    this.header = page.locator('h1');
  }

  // Méthode pour naviguer vers la page d'accueil
  async navigate(): Promise<void> {
    await this.page.goto('https://playwright.dev/');
  }

  // Méthode pour récupérer le texte du titre
  async getHeaderText(): Promise<string | null> {
    return this.header.textContent();
  }
}
```

#### Exemple d’utilisation

```typescript
// tests/homepage.spec.ts
import { test, expect } from '@playwright/test';
import { PlaywrightHomePage } from '../pages/PlaywrightHomePage';

test.describe('Test du site Playwright', () => {
  test('Vérifier que le titre principal contient "Playwright"', async ({ page }) => {
    // Instanciation de la page via notre Page Object
    const homePage = new PlaywrightHomePage(page);
    await homePage.navigate();

    const headerText = await homePage.getHeaderText();

    expect(headerText).toContain('Playwright');
  });
});
```

### Avantages

- **Séparation des responsabilités** :  
Le POM sépare la logique de test de l’implémentation de l’interface. Cela permet aux tests de se concentrer sur la validation du comportement métier.
- **Modularité et évolutivité** :  
Chaque page ou composant est représenté par une classe spécifique, facilitant ainsi l’organisation et l’évolution de la suite de tests.
- **Maintenance facilitée** :  
Lorsqu'une modification est apportée à l'interface (changement de sélecteur, structure HTML modifiée…), il suffit de mettre à jour la classe correspondante, sans toucher aux tests eux-mêmes.
- **Réutilisabilité** :  
Les méthodes et sélecteurs encapsulés dans un objet peuvent être réutilisés dans plusieurs tests, réduisant ainsi la duplication de code.
- **Lisibilité et clarté des tests** :  
En déléguant les interactions à des objets dédiés, les scénarios de tests restent concis et lisibles. On peut ainsi comprendre rapidement l’intention du test sans se perdre dans les détails d’implémentation.

### Inconvénients

- Risque de duplication si mal structuré :  
Sans une bonne conception, on peut se retrouver avec des classes qui dupliquent des comportements similaires pour des composants récurrents, au lieu d’extraire des composants communs. Dans le cas où on trouverait plusieurs fois le même composant sur une page, il suffit d’y accéder en précisant le bloc parent dans le sélecteur.
- Couplage si contenu dans une librairie à part :  
Conserver le POM dans un repository / une librairie à part entraîne des problèmes d’alignement des sélecteurs lors de mise à jour des pages.

## Screenplay Pattern : alternative au POM

Le Screenplay Pattern est une approche pour structurer les tests d'UI en mettant l'accent sur les actions et les intentions des utilisateur·ices, plutôt que sur la structure technique des pages. Particulièrement utile pour des **suites de tests larges et évolutives**.

Au lieu de manipuler directement les éléments de l’UI via un Page Object Model (POM), il introduit des "acteur·ices" qui interagissent avec l'interface en utilisant des "tâches" et des "questions".

### Exemples de code avec Playwright

```typescript
import { Page } from '@playwright/test';

// Définition des intéractions
export class EnterText {
  static into(selector: string, text: string) {
    return async (page: Page) => {
      await page.fill(selector, text);
    };
  }
}

export class Click {
  static on(selector: string) {
    return async (page: Page) => {
      await page.click(selector);
    };
  }
}

// Définition des tâches
export class Login {
  static withCredentials(username: string, password: string) {
    return async (page: Page) => {
      await EnterText.into('#username', username)(page);
      await EnterText.into('#password', password)(page);
      await Click.on('#login-button')(page);
    };
  }
}

// Définition des questions
export class IsLoggedIn {
  static async answeredBy(page: Page) {
    return await page.locator('#welcome-message').isVisible();
  }
}
```

#### Exemple d’utilisation

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';
import { Login, IsLoggedIn } from './login-screenplay';

test('Alice peut se connecter', async ({ page }) => {
  await page.goto('https://example.com/login');

  // L'utilisateur·ice joue le rôle d'un·e acteur·ice réalisant une tâche
  await Login.withCredentials('alice', 'securepassword')(page);

  // Vérification de la connexion
  const loggedIn = await IsLoggedIn.answeredBy(page);
  expect(loggedIn).toBe(true);
});
```

### Avantages

- **Modularité** :  
Les interactions et tâches sont réutilisables.
- **Lisibilité** :  
Le code ressemble plus à un scénario utilisateur.
- **Maintenance facilitée** :  
Modifier l’implémentation d’une interaction ne casse pas toute la suite de tests.
- **Scalabilité** :  
Facilite l’ajout de nouvelles tâches sans dupliquer du code.

### Inconvénients

- **Complexité initiale** :  
Plus de fichiers et d'abstraction qu'un simple Page Object Model qui est parfois suffisant pour de petits tests simple.
- **Courbe d’apprentissage** :  
Nécessite de bien comprendre la séparation entre acteurs, tâches et interactions.
