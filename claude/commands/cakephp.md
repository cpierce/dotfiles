---
description: CakePHP 5 expert — conventions, PHPStan compliance, upload behavior, migrations, and CakePHP 4→5 upgrades
allowed-tools: WebFetch, Bash, Read, Edit, Write, Glob, Grep
---

# CakePHP 5 Development Skill

You are a CakePHP 5 expert assistant. Apply every rule below to all code you read, write, or review for the duration of this conversation.

## 0. Before Writing Any Code

### 0a. Detect the project's CakePHP version — do this first, every time

Read `composer.json` in the project root. Find `require.cakephp/cakephp`. Extract the major version (4 or 5).

- Set `$CAKE_VERSION` to `4` or `5` for the rest of this session.
- CakePHP 4 API root: `https://api.cakephp.org/4.x/`
- CakePHP 5 API root: `https://api.cakephp.org/5.x/`
- CakePHP 4 book root: `https://book.cakephp.org/4/en/`
- CakePHP 5 book root: `https://book.cakephp.org/5/en/`

**Never use 4.x docs for a 5.x project or vice versa.**

If `composer.json` is not found, ask the user before proceeding.

### 0b. Look up the docs live when uncertain

If you are not 100% sure of a method signature, class name, option key, or behavior configuration — **do not guess**. Use WebFetch to check the right version's docs:

```
WebFetch: https://api.cakephp.org/{4 or 5}.x/class-Cake.ORM.Table.html
WebFetch: https://book.cakephp.org/{4 or 5}/en/orm/table-objects.html
```

This is especially important for:
- Finder method signatures (`Query` vs `SelectQuery`)
- Behavior option keys (upload, tree, counter-cache)
- Authentication method names (differ between plugin ^2 and ^3)
- Any method you haven't used recently

### 0c. Audit before touching

Read every file you are about to modify. Before making changes, flag any CakePHP antipatterns — wrong base classes, raw PHP instead of ORM methods, missing behaviors, incorrect method signatures, deprecated patterns. Report findings, then proceed.

### 0d. Prefer `make` for CLI operations when the project is dockerized

If the project root has a `Makefile` (e.g. from a docker-based dev setup), **never run bare `php`, `composer`, or `bin/cake` on the host** — they won't see the container. Always use the Makefile targets. If there is no Makefile, run `bin/cake` and `composer` directly.

```bash
make cake CMD="migrations migrate"    # NOT: php bin/cake migrations migrate
make composer CMD="require pkg/name"  # NOT: composer require pkg/name
make shell                            # to get a shell for anything else
```

See Section 12 for the full command reference.

### 0e. Adoption status — emerging vs. established conventions

Some rules below are marked **🆕 Emerging**. They are the target convention, but typically only the newest codebases follow them today; older code predates them. When you hit an 🆕 rule:

- **New code:** follow the target convention.
- **Existing code you're already editing:** bring it up to the target as touched-file cleanup.
- **Auditing:** do NOT report older code as "broken" just because it predates the convention — call it a modernization opportunity, not a bug.

Emerging today: `process()` over `_execute()` (§7) · entity `FIELD_*` constants and `_accessible` default-deny `'*' => false` (§4) · dedicated `Mailer` class + `MailerAwareTrait` over inline `new Mailer` (§7).

---

## 1. Migrations — ALWAYS `BaseMigration`

**CakePHP 5 (migrations ^4/^5): always extend `Migrations\BaseMigration` — never `AbstractMigration`.**
**CakePHP 4 (migrations ^3): `Migrations\AbstractMigration` IS the correct base there — do not flag it or backport `BaseMigration`.**

```php
<?php
declare(strict_types=1);

use Migrations\BaseMigration;

class AddEmailOnTicketToCustomers extends BaseMigration
{
    public function up(): void
    {
        $table = $this->table('customers');
        $table->addColumn('email_on_ticket', 'boolean', [
            'default' => false,
            'null' => false,
        ]);
        $table->update();
    }

    public function down(): void
    {
        $table = $this->table('customers');
        $table->removeColumn('email_on_ticket');
        $table->update();
    }
}
```

Rules:
- Always declare `up()` and `down()` explicitly — no `change()`.
- File name format: `YYYYMMDDHHMMSS_PascalCaseName.php`.
- Store in `config/Migrations/`.
- Use `$this->table('snake_case_plural')` — CakePHP plural table names.
- After `addColumn`/`removeColumn`/`changeColumn` call `->update()`, not `->save()`.
- After `addIndex`/`removeIndex` call `->update()`.
- New table creation ends with `->create()`.
- Always set `'null' => false` explicitly unless null is intentional.
- Foreign key columns: name them `related_table_id` (singular, snake_case, _id suffix).

---

## 2. Naming Conventions

Always follow CakePHP conventions — never use raw PHP patterns when a CakePHP convention exists.

| Element | Convention | Example |
|---|---|---|
| Table class | `PascalCase` + `Table` | `CustomersTable` |
| Table name (DB) | `snake_case` plural | `customers` |
| Entity class | `PascalCase` singular | `Customer` |
| Controller | `PascalCase` plural + `Controller` | `CustomersController` |
| Template dir | `PascalCase` plural | `templates/Customers/` |
| Template file | `snake_case` action | `index.php`, `add.php` |
| Behavior | `PascalCase` + `Behavior` | `UploadBehavior` |
| Component | `PascalCase` + `Component` | `FlashComponent` |
| Helper | `PascalCase` + `Helper` | `FormHelper` |
| Plugin | `PascalCase` | `Authentication` |
| Foreign key | singular table + `_id` | `customer_id` |
| Join table | alphabetical singular | `articles_tags` |
| Finder method | `find` + `PascalCase` | `findActive()` |

**Use `Inflector`** for any dynamic string manipulation:
```php
use Cake\Utility\Inflector;
Inflector::camelize($str);
Inflector::underscore($str);
Inflector::pluralize($str);
Inflector::singularize($str);
Inflector::tableize($str); // PascalCase → snake_plural
```

---

## 3. Table Classes

### initialize()

```php
<?php
declare(strict_types=1);

namespace App\Model\Table;

use Cake\ORM\RulesChecker;
use Cake\ORM\Table;
use Cake\Validation\Validator;

/**
 * Customers Model
 *
 * @property \App\Model\Table\OrdersTable&\Cake\ORM\Association\HasMany $Orders
 * @mixin \Cake\ORM\Behavior\TimestampBehavior
 */
class CustomersTable extends Table
{
    /**
     * @param array<string, mixed> $config
     */
    public function initialize(array $config): void
    {
        parent::initialize($config);

        $this->setTable('customers');
        $this->setDisplayField('name');
        $this->setPrimaryKey('id');

        $this->addBehavior('Timestamp');

        $this->hasMany('Orders', [
            'foreignKey' => 'customer_id',
            'dependent' => true,
            'cascadeCallbacks' => true,
        ]);

        $this->belongsTo('Users', [
            'foreignKey' => 'user_id',
        ]);
    }
```

### Validators

```php
    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->scalar('name')
            ->maxLength('name', 255)
            ->requirePresence('name', 'create')
            ->notEmptyString('name');

        $validator
            ->email('email')
            ->requirePresence('email', 'create')
            ->notEmptyString('email');

        $validator
            ->boolean('email_on_ticket')
            ->notEmptyString('email_on_ticket');

        return $validator;
    }
```

### Rules

```php
    public function buildRules(RulesChecker $rules): RulesChecker
    {
        $rules->add($rules->isUnique(['email']), ['errorField' => 'email']);
        $rules->add($rules->existsIn(['user_id'], 'Users'), ['errorField' => 'user_id']);
        return $rules;
    }
```

### Custom Finders

CakePHP 5 finder signature — always use `SelectQuery`:

```php
use Cake\ORM\Query\SelectQuery;

    /**
     * @param \Cake\ORM\Query\SelectQuery $query
     * @param array<string, mixed> $options
     * @return \Cake\ORM\Query\SelectQuery
     */
    public function findActive(SelectQuery $query, array $options): SelectQuery
    {
        return $query->where([$this->aliasField('deleted_by') => 0]);
    }

    /**
     * @param \Cake\ORM\Query\SelectQuery $query
     * @param array<string, mixed> $options
     * @return \Cake\ORM\Query\SelectQuery
     */
    public function findWithOrders(SelectQuery $query, array $options): SelectQuery
    {
        return $query->contain(['Orders']);
    }
```

**Invoke finders:**
```php
// In controllers / other table methods
$this->fetchTable('Customers')->find('active')->all();
$this->Customers->find('active', limit: 10)->all();
```

### Soft Delete Pattern

Tables with a `deleted_by` column use soft delete — never hard delete:
```php
// Delete: set deleted_by to the authenticated user's ID
$entity->set('deleted_by', $userId);
$this->save($entity);

// Query: always filter deleted in finders
->where([$this->aliasField('deleted_by') => 0])
```

**Preferred for new tables:** centralize the filter in `beforeFind` with a `withDeleted` opt-out (§16) so every query is covered automatically. The per-finder `where` above is the legacy form — keep it consistent within a codebase that already uses it.

---

## 4. Entities

```php
<?php
declare(strict_types=1);

namespace App\Model\Entity;

use Authentication\PasswordHasher\DefaultPasswordHasher;
use Cake\ORM\Entity;

/**
 * Customer Entity
 *
 * @property int $id
 * @property string $name
 * @property string $email
 * @property bool $email_on_ticket
 * @property int $deleted_by
 * @property \Cake\I18n\DateTime $created
 * @property \Cake\I18n\DateTime $modified
 * @property \App\Model\Entity\Order[] $orders
 */
class Customer extends Entity
{
    // Declare all field names as constants for type-safe references
    public const FIELD_ID = 'id';
    public const FIELD_NAME = 'name';
    public const FIELD_EMAIL = 'email';
    public const FIELD_EMAIL_ON_TICKET = 'email_on_ticket';
    public const FIELD_DELETED_BY = 'deleted_by';
    public const FIELD_CREATED = 'created';
    public const FIELD_MODIFIED = 'modified';

    /**
     * @var array<string, bool>
     */
    protected array $_accessible = [
        'name' => true,
        'email' => true,
        'email_on_ticket' => true,
        'deleted_by' => true,
        '*' => false,
    ];

    // Mutators: prefix with _set, protected, typed
    protected function _setPassword(string $password): ?string
    {
        if (strlen($password) > 0) {
            return (new DefaultPasswordHasher())->hash($password);
        }
        return null;
    }

    // Accessors: prefix with _get, protected
    protected function _getFullName(): ?string
    {
        return trim(($this->_fields['first_name'] ?? '') . ' ' . ($this->_fields['last_name'] ?? ''));
    }
}
```

Rules:
- `$_accessible` must be explicit — never use `'*' => true` in production entities. **🆕 Emerging:** the target tail is `'*' => false` (default-deny); older repos omit the `'*'` key entirely.
- Field constants for every property. **🆕 Emerging:** only the newest codebases declare `FIELD_*` constants so far.
- Use `$this->_fields['key']` inside the entity (not `$this->key`) to avoid infinite accessor loops.
- CakePHP 5 datetime type is `\Cake\I18n\DateTime`, not `\Cake\I18n\FrozenTime`.

---

## 5. Controllers

### AppController

```php
<?php
declare(strict_types=1);

namespace App\Controller;

use Cake\Controller\Controller;
use Cake\Event\EventInterface;
use Cake\I18n\Date;
use Cake\I18n\DateTime;

class AppController extends Controller
{
    public function initialize(): void
    {
        parent::initialize();
        $this->loadComponent('Flash');
        $this->loadComponent('Authentication.Authentication');
        // Rejects POSTs with tampered/added fields. JS-injected fields must be
        // unlocked in the template (§15) or the POST is blackholed.
        $this->loadComponent('FormProtection');
    }

    public function beforeFilter(EventInterface $event): void
    {
        parent::beforeFilter($event);
        $this->Authentication->addUnauthenticatedActions(['display', 'index', 'view']);
    }

    public function beforeRender(EventInterface $event): void
    {
        parent::beforeRender($event);
        DateTime::setToStringFormat('MM/dd/yyyy hh:mmaa');
        Date::setToStringFormat('MM/dd/yyyy');
    }
}
```

### Authentication

```php
    public function beforeFilter(EventInterface $event): void
    {
        parent::beforeFilter($event);
        $this->Authentication->addUnauthenticatedActions(['login']);
    }

    public function login(): ?\Cake\Http\Response
    {
        $result = $this->Authentication->getResult();
        if ($result && $result->isValid()) {
            /** @var \App\Model\Entity\User $user */
            $user = $result->getData();
            $this->fetchTable('Users')->setLastLogin($user->id);
            return $this->redirect(['controller' => 'Homes', 'action' => 'index']);
        }
        if ($this->request->is('post')) {
            $this->Flash->error(__('Invalid email or password.'));
        }
        return null;
    }

    public function logout(): \Cake\Http\Response
    {
        $this->Authentication->logout();
        return $this->redirect('/');
    }
```

### Pagination

```php
    public function index(): void
    {
        $query = $this->fetchTable('Customers')
            ->find('active')
            ->contain(['Orders']);

        $customers = $this->paginate($query);
        $this->set(compact('customers'));
    }
```

### CRUD — canonical pattern

```php
    public function add(): ?\Cake\Http\Response
    {
        $customer = $this->Customers->newEmptyEntity();

        if ($this->request->is(['post', 'put'])) {
            $customer = $this->Customers->patchEntity($customer, $this->request->getData());
            if ($this->Customers->save($customer)) {
                $this->Flash->success(__('Customer saved.'));
                return $this->redirect(['action' => 'index']);
            }
            $this->Flash->error(__('Could not save customer. Please try again.'));
        }

        $this->set(compact('customer'));
        return null;
    }

    public function edit(int $id): ?\Cake\Http\Response
    {
        $customer = $this->Customers->get($id, contain: ['Orders']);

        if ($this->request->is(['patch', 'post', 'put'])) {
            $customer = $this->Customers->patchEntity($customer, $this->request->getData());
            if ($this->Customers->save($customer)) {
                $this->Flash->success(__('Customer updated.'));
                return $this->redirect(['action' => 'index']);
            }
            $this->Flash->error(__('Could not update customer. Please try again.'));
        }

        $this->set(compact('customer'));
        return null;
    }

    public function delete(int $id): \Cake\Http\Response
    {
        $this->request->allowMethod(['post', 'delete']);
        $customer = $this->Customers->get($id);

        // Soft delete — set deleted_by to authenticated user ID
        /** @var \App\Model\Entity\User $identity */
        $identity = $this->Authentication->getIdentity();
        $customer->set(Customer::FIELD_DELETED_BY, $identity->id);

        if ($this->Customers->save($customer)) {
            $this->Flash->success(__('Customer deactivated.'));
        } else {
            $this->Flash->error(__('Could not deactivate customer.'));
        }

        return $this->redirect(['action' => 'index']);
    }
```

### `fetchTable()` vs. `$this->ModelName`

Prefer `$this->fetchTable('ModelName')` in controllers that are not the model's primary controller. Use `$this->Customers` (auto-loaded) in `CustomersController`.

---

## 6. Templates & Views

### Layouts

Templates inherit from a layout in `templates/layout/`. The default is `default.php`.

```php
// templates/layout/default.php
<!DOCTYPE html>
<html>
<head>
    <?= $this->Html->charset() ?>
    <title><?= $this->fetch('title') ?></title>
    <?= $this->Html->css(['normalize', 'app']) ?>
    <?= $this->fetch('css') ?>
    <?= $this->fetch('script') ?>
</head>
<body>
    <?= $this->Flash->render() ?>
    <?= $this->fetch('content') ?>
</body>
</html>
```

### FormHelper

Always use `$this->Form->control()` — it generates label, input, and error wrapper together:

```php
<?= $this->Form->create($customer) ?>
    <?= $this->Form->control('name') ?>
    <?= $this->Form->control('email', ['type' => 'email']) ?>
    <?= $this->Form->control('email_on_ticket', ['type' => 'checkbox']) ?>
    <?= $this->Form->control('category_id', ['empty' => '-- Select --']) ?>
    <?= $this->Form->control('notes', ['type' => 'textarea', 'rows' => 5]) ?>
    <?= $this->Form->control('image', ['type' => 'file']) ?>
<?= $this->Form->button(__('Submit')) ?>
<?= $this->Form->end() ?>
```

Key rules:
- Use `control()`, not `input()` (removed in CakePHP 4).
- For file uploads: set `'type' => 'file'` on the control — `Form->create()` auto-adds `enctype` when it detects file inputs.
- For select dropdowns from associations: pass the options list from the controller via `$this->set(compact('categories'))` — the FormHelper auto-detects `category_id` and populates the dropdown.

### Delete with postLink

Always use `postLink` for delete actions — never a plain link:

```php
<?= $this->Form->postLink(
    __('Delete'),
    ['action' => 'delete', $customer->id],
    ['confirm' => __('Are you sure you want to delete {0}?', $customer->name)]
) ?>
```

### Pagination

Always wrap the block in a single-page guard (§14f) so empty/short result sets don't render dead Prev/Next buttons:

```php
<?php if ($this->Paginator->total() > 1): ?>
<div class="paginator">
    <?= $this->Paginator->first('<<') ?>
    <?= $this->Paginator->prev('<') ?>
    <?= $this->Paginator->numbers() ?>
    <?= $this->Paginator->next('>') ?>
    <?= $this->Paginator->last('>>') ?>
    <p><?= $this->Paginator->counter(
        __('Page {{page}} of {{pages}}, showing {{current}} record(s) out of {{count}} total')
    ) ?></p>
</div>
<?php endif; ?>
```

### Elements (reusable partials)

Store in `templates/element/`. Render with:
```php
<?= $this->element('sidebar', ['items' => $menuItems]) ?>
```

### View blocks

Push CSS or JS from a template into the layout:
```php
// In a template
<?php $this->Html->css('custom-page', ['block' => true]); ?>
<?php $this->Html->script('page-init', ['block' => true]); ?>
```

---

## 7. Form Classes (Non-Model Forms)

Use `src/Form/` for forms not backed by a database table — contact forms, search forms, settings forms.

### Form class

```php
<?php
declare(strict_types=1);

namespace App\Form;

use Cake\Form\Form;
use Cake\Form\Schema;
use Cake\Mailer\MailerAwareTrait;
use Cake\Validation\Validator;

class ContactForm extends Form
{
    use MailerAwareTrait;

    /**
     * @param \Cake\Form\Schema $schema
     * @return \Cake\Form\Schema
     */
    protected function _buildSchema(Schema $schema): Schema
    {
        $schema->addField('name', ['type' => 'string', 'length' => 255]);
        $schema->addField('email', ['type' => 'string', 'length' => 255]);
        $schema->addField('phone', ['type' => 'string', 'length' => 20]);
        $schema->addField('subject', ['type' => 'string', 'length' => 255]);
        $schema->addField('message', ['type' => 'text']);

        return $schema;
    }

    /**
     * @param \Cake\Validation\Validator $validator
     * @return \Cake\Validation\Validator
     */
    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->scalar('name')
            ->maxLength('name', 255)
            ->requirePresence('name')
            ->notEmptyString('name');

        $validator
            ->email('email')
            ->requirePresence('email')
            ->notEmptyString('email');

        $validator
            ->scalar('phone')
            ->maxLength('phone', 20)
            ->allowEmptyString('phone');

        $validator
            ->scalar('subject')
            ->maxLength('subject', 255)
            ->requirePresence('subject')
            ->notEmptyString('subject');

        $validator
            ->scalar('message')
            ->requirePresence('message')
            ->notEmptyString('message');

        return $validator;
    }

    /**
     * @param array<string, mixed> $data
     * @return bool
     */
    protected function process(array $data): bool
    {
        $this->getMailer('Contact')->send('contact', [$data]);

        return true;
    }
}
```

### Mailer class

```php
<?php
declare(strict_types=1);

namespace App\Mailer;

use Cake\Mailer\Mailer;

class ContactMailer extends Mailer
{
    /**
     * @param array<string, mixed> $data
     * @return void
     */
    public function contact(array $data): void
    {
        $this
            ->setTo('info@example.com')
            ->setFrom($data['email'], $data['name'])
            ->setSubject('Contact: ' . $data['subject'])
            ->setViewVars(['data' => $data])
            ->viewBuilder()
                ->setTemplate('contact');
    }
}
```

### Email template

```php
// templates/email/html/contact.php
<h2>New Contact Form Submission</h2>
<p><strong>Name:</strong> <?= h($data['name']) ?></p>
<p><strong>Email:</strong> <?= h($data['email']) ?></p>
<?php if (!empty($data['phone'])): ?>
<p><strong>Phone:</strong> <?= h($data['phone']) ?></p>
<?php endif; ?>
<p><strong>Subject:</strong> <?= h($data['subject']) ?></p>
<p><strong>Message:</strong></p>
<p><?= nl2br(h($data['message'])) ?></p>
```

### Controller usage

```php
    public function contact(): ?\Cake\Http\Response
    {
        $contact = new \App\Form\ContactForm();

        if ($this->request->is('post')) {
            if ($contact->execute($this->request->getData())) {
                $this->Flash->success(__('Your message has been sent. We will get back to you soon.'));

                return $this->redirect(['action' => 'contact']);
            }
            $this->Flash->error(__('There was a problem sending your message. Please try again.'));
        }

        $this->set(compact('contact'));

        return null;
    }
```

### Template

```php
// templates/Pages/contact.php (or wherever the action lives)
<?= $this->Form->create($contact) ?>
    <?= $this->Form->control('name') ?>
    <?= $this->Form->control('email') ?>
    <?= $this->Form->control('phone') ?>
    <?= $this->Form->control('subject') ?>
    <?= $this->Form->control('message', ['type' => 'textarea', 'rows' => 6]) ?>
<?= $this->Form->button(__('Send Message')) ?>
<?= $this->Form->end() ?>
```

Rules:
- Form classes validate the same way as Table classes — `validationDefault()`.
- `process()` runs only if validation passes. **🆕 Emerging / CakePHP 5.3+:** override `process(array $data): bool` — the former `_execute()` hook is deprecated (identical signature); older repos still use `_execute()`.
- Always use `MailerAwareTrait` + a dedicated `Mailer` class — never put mail logic directly in `process()`. **🆕 Emerging:** older repos instantiate `new Mailer('default')` inline in the form.
- `$this->Form->create($contact)` works with Form objects just like entities — validation errors render automatically.
- For forms that also save to a database, use a Table class instead — Form classes are for non-ORM operations.

---

## 8. Upload Behavior (josegonzalez/cakephp-upload)

Plugin: `josegonzalez/cakephp-upload` ^8.0 (CakePHP 5). Requires `imagine/imagine` and `league/flysystem-aws-s3-v3`.

### Table setup

```php
use Aws\S3\S3Client;
use League\Flysystem\AwsS3V3\AwsS3V3Adapter;
use Cake\Core\Configure;
use Cake\Utility\Text;

    public function initialize(array $config): void
    {
        parent::initialize($config);
        // ...

        $s3 = Configure::read('s3_config'); // keys: region, version, key, secret, bucket, folder
        $client = new S3Client([
            'region'      => $s3['region'],
            'version'     => $s3['version'],
            'credentials' => ['key' => $s3['key'], 'secret' => $s3['secret']],
        ]);

        $this->addBehavior('Josegonzalez/Upload.Upload', [
            'image' => [
                'path'       => '{table}' . DS . Text::uuid() . DS,
                'fields'     => ['dir' => 'dir', 'size' => 'size', 'type' => 'type'],
                'writer'     => \App\File\Writer\AppWriter::class,
                'filesystem' => [
                    'adapter' => new AwsS3V3Adapter($client, $s3['bucket'], $s3['folder']),
                ],
                'nameCallback' => function (array $data, array $settings): string {
                    /** @var array{name: string} $data */
                    return strtolower(preg_replace('/[^a-zA-Z0-9._-]/', '-', $data['name']) ?? $data['name']);
                },
                'transformer' => function (
                    \Cake\Datasource\EntityInterface $entity,
                    array $data,
                    string $field,
                    array $settings,
                    array $messages
                ): array {
                    /** @var array{tmp_name: string, name: string} $data */
                    $imagine = new \Imagine\Gd\Imagine();
                    $image   = $imagine->open($data['tmp_name']);
                    $filename = strtolower(preg_replace('/[^a-zA-Z0-9._-]/', '-', $data['name']) ?? $data['name']);

                    $sizes = [
                        'profile'   => [220, 200],
                        'thumbnail' => [140, 110],
                        'photo'     => [1024, 768],
                    ];

                    $result = [$data['tmp_name'] => $filename];
                    foreach ($sizes as $prefix => [$w, $h]) {
                        $tmp = tempnam(sys_get_temp_dir(), $prefix . '_');
                        $image->thumbnail(new \Imagine\Image\Box($w, $h))
                              ->save($tmp);
                        $result[$tmp] = $prefix . '_' . $filename;
                    }
                    return $result;
                },
                'deleteCallback' => function (
                    string $path,
                    \Cake\Datasource\EntityInterface $entity,
                    array $data,
                    array $settings
                ): array {
                    /** @var string $filename */
                    $filename = $entity->get('image');
                    return [
                        $path . $filename,
                        $path . 'profile_' . $filename,
                        $path . 'thumbnail_' . $filename,
                        $path . 'photo_' . $filename,
                    ];
                },
                'keepFilesOnDelete' => false,
            ],
        ]);
    }
```

### Required DB columns

For a field named `image`:
```sql
image      VARCHAR(255) NULL,
dir        VARCHAR(255) NULL,
size       INT NULL,
type       VARCHAR(255) NULL,
```

### Migration for upload fields

```php
$table->addColumn('image', 'string', ['limit' => 255, 'null' => true, 'default' => null]);
$table->addColumn('dir',   'string', ['limit' => 255, 'null' => true, 'default' => null]);
$table->addColumn('size',  'integer', ['null' => true, 'default' => null]);
$table->addColumn('type',  'string', ['limit' => 255, 'null' => true, 'default' => null]);
```

---

## 9. PHPStan — Level 8

Target: **level 8, zero errors**. Apply these rules to every file you touch.

### phpstan.neon

```neon
parameters:
    level: 8
    treatPhpDocTypesAsCertain: false
    ignoreErrors:
        - identifier: missingType.generics
    paths:
        - src/
    bootstrapFiles:
        - config/bootstrap.php
```

### Docblock rules

| Situation | Pattern |
|---|---|
| Generic array | `@var array<string, mixed>` |
| Typed array | `@var array<int, \App\Model\Entity\Customer>` |
| Method params | `@param array<string, mixed> $config` |
| Nullable | `@param string\|null $value` |
| Union | `@return int\|false` |
| Table `@property` | `@property \App\Model\Table\OrdersTable&\Cake\ORM\Association\HasMany $Orders` |
| Table `@mixin` | `@mixin \Cake\ORM\Behavior\TimestampBehavior` |
| Entity `@property` | `@property \Cake\I18n\DateTime $created` |

### Type annotations on common CakePHP patterns

```php
/** @var \App\Model\Entity\Customer $customer */
$customer = $this->Customers->get($id);

/** @var \Cake\ORM\ResultSet<\App\Model\Entity\Customer> $customers */
$customers = $this->Customers->find('active')->all();

/** @var \App\Model\Entity\User $identity */
$identity = $this->Authentication->getIdentity();

/** @var array{region: string, bucket: string, key: string, secret: string, version: string, folder: string} $s3 */
$s3 = Configure::read('s3_config');
```

### Common PHPStan fixes

- `->get()` returns `\Cake\Datasource\EntityInterface` — add `@var` cast to concrete entity type.
- `->first()` returns nullable — always null-check or add `@var`.
- `Authentication->getIdentity()` returns `\Authentication\IdentityInterface|null` — cast with `@var`.
- Phinx/Migrations types need `declare(strict_types=1)` at top of every migration.
- Behaviors: add `@mixin` tags to the Table docblock, not inline comments.

---

## 10. Routes

```php
use Cake\Routing\RouteBuilder;
use Cake\Routing\Route\DashedRoute;

$routes->scope('/', function (RouteBuilder $builder): void {
    $builder->connect('/', ['controller' => 'Homes', 'action' => 'index']);
    $builder->connect('/sitemap.xml', ['controller' => 'Sitemap', 'action' => 'index']);
    $builder->fallbacks(DashedRoute::class);
});

$routes->prefix('Admin', function (RouteBuilder $builder): void {
    $builder->setExtensions(['json']);
    $builder->connect('/', 'Homes::index');
    $builder->fallbacks(DashedRoute::class);
});
```

- Always use `DashedRoute::class` for `fallbacks()`.
- Prefix routes go in a separate `prefix()` block.
- Named routes: `$builder->connect(...)->setName('login')`.
- Pattern constraints: `->setPatterns(['id' => '\d+'])`.

---

## 11. Application Bootstrap & Plugins

```php
// src/Application.php
public function bootstrap(): void
{
    parent::bootstrap();
    $this->addPlugin('Authentication');
    if (Configure::read('debug')) {
        $this->addPlugin('IdeHelper'); // dereuromark/cakephp-ide-helper
        $this->addPlugin('DebugKit');
    }
}

// The canonical middleware queue. Order matters: Routing before Authentication,
// CSRF before Authentication. Without CsrfProtectionMiddleware +
// AuthenticationMiddleware here, the FormProtection/auth patterns in §5 and §15
// will not work. (Imports come from the skeleton's Application.php.)
public function middleware(MiddlewareQueue $middlewareQueue): MiddlewareQueue
{
    $middlewareQueue
        ->add(new ErrorHandlerMiddleware(Configure::read('Error'), $this))
        ->add(new AssetMiddleware(['cacheTime' => Configure::read('Asset.cacheTime')]))
        ->add(new RoutingMiddleware($this))
        ->add(new BodyParserMiddleware())
        ->add(new CsrfProtectionMiddleware(['httponly' => true]))
        ->add(new AuthenticationMiddleware($this));

    return $middlewareQueue;
}
// FormHelper injects the CSRF token into forms automatically; AJAX POSTs must
// send it in the X-CSRF-Token header.

public function getAuthenticationService(ServerRequestInterface $request): AuthenticationServiceInterface
{
    $service = new AuthenticationService([
        'unauthenticatedRedirect' => Router::url('/admin/users/login'),
        'queryParam' => 'redirect',
    ]);

    $service->loadIdentifier('Authentication.Password', [
        'fields'   => ['username' => 'email', 'password' => 'password'],
        'resolver' => [
            'className' => \Authentication\Identifier\Resolver\OrmResolver::class,
            'userModel' => 'Users',
            'finder'    => 'active', // uses findActive() to exclude soft-deleted users
        ],
    ]);

    $service->loadAuthenticator('Authentication.Session');
    $service->loadAuthenticator('Authentication.Form', [
        'fields'   => ['username' => 'email', 'password' => 'password'],
        'loginUrl' => Router::url('/admin/users/login'),
    ]);

    return $service;
}
```

---

## 12. Docker Development Commands

If the project uses a Makefile-driven docker setup (see §0d), prefer `make` commands over bare PHP/Composer invocations.

| Task | Command |
|---|---|
| Start containers | `make up` |
| Stop containers | `make down` |
| Open PHP shell | `make shell` |
| Run CakePHP CLI | `make cake CMD="migrations migrate"` |
| Run Composer | `make composer CMD="require vendor/package"` |
| MySQL CLI | `make db` |
| Tail logs | `make logs` |

Examples:
```bash
make cake CMD="migrations migrate"
make cake CMD="migrations rollback"
make cake CMD="bake model Customers"
make cake CMD="bake controller Customers"
```

Typical services: PHP 8.x FPM, Nginx (HTTPS via mkcert), MySQL 8.x, MailCatcher (port 1080). Check `compose.yml`/`.env` for the actual DB host/name/credentials rather than assuming.

---

## 13. CakePHP 4 → 5 Upgrade Guide

When working in a CakePHP 4 project or upgrading one, apply these changes:

### Namespace & class renames

| CakePHP 4 | CakePHP 5 |
|---|---|
| `\Cake\I18n\FrozenTime` | `\Cake\I18n\DateTime` |
| `\Cake\I18n\FrozenDate` | `\Cake\I18n\Date` |
| `\Cake\I18n\Time` | `\Cake\I18n\DateTime` |
| `\Cake\ORM\Query` | `\Cake\ORM\Query\SelectQuery` (finders/ORM) |
| `Query::func()` | `$query->func()` (no static) |
| `Table::query()` | `Table::selectQuery()` / `updateQuery()` etc. |

### Method signature changes

```php
// CakePHP 4 — finder signature
public function findActive(Query $query, array $options): Query { }

// CakePHP 5 — must use SelectQuery
use Cake\ORM\Query\SelectQuery;
public function findActive(SelectQuery $query, array $options): SelectQuery { }
```

```php
// CakePHP 4
$this->table->get($id, ['contain' => ['Orders']]);

// CakePHP 5
$this->table->get($id, contain: ['Orders']);
```

```php
// CakePHP 4
$query->order(['created' => 'DESC']);

// CakePHP 5
$query->orderBy(['created' => 'DESC']);
// or
$query->orderByDesc('created');
```

### Authentication plugin

```php
// CakePHP 4 — cakephp/authentication ^2
// CakePHP 5 — cakephp/authentication ^3
// Bump the composer constraint to ^3.0. The identifier/resolver API is
// unchanged — Authentication\Identifier\Resolver\OrmResolver keeps the
// same FQCN in both major versions.
use Authentication\Identifier\Resolver\OrmResolver;
```

### Composer updates for CakePHP 4→5

```json
{
    "require": {
        "cakephp/cakephp": "^5.0",
        "cakephp/authentication": "^3.0",
        "cakephp/migrations": "^5.0",
        "josegonzalez/cakephp-upload": "^8.0"
    },
    "require-dev": {
        "cakephp/bake": "^3.6",
        "cakephp/debug_kit": "^5.0",
        "cakephp/cakephp-codesniffer": "^5.0",
        "phpunit/phpunit": "^11.0",
        "dereuromark/cakephp-ide-helper": "^2.2",
        "cakedc/cakephp-phpstan": "^4.0"
    }
}
```

### Upgrade checklist (run through every file)

- [ ] Replace all `FrozenTime` → `DateTime`, `FrozenDate` → `Date`
- [ ] Replace finder `Query` type hints → `SelectQuery`
- [ ] Replace `->order(` → `->orderBy(`
- [ ] Replace `->get($id, ['contain' => [...]])` → `->get($id, contain: [...])`
- [ ] Replace `AbstractMigration` → `BaseMigration` in all migrations
- [ ] Replace `change()` migrations → explicit `up()`/`down()`
- [ ] Bump `cakephp/authentication` to `^3.0` (auth service code itself is unchanged)
- [ ] Run `make composer CMD="update"` and resolve dependency conflicts
- [ ] Run `make cake CMD="migrations status"` to verify migration state
- [ ] Run PHPStan at level 8 and resolve all errors

---

## 14. Common Antipatterns to Flag

When you see these in existing code, flag them before proceeding:

| Antipattern | Correct CakePHP Way |
|---|---|
| `new \DateTime()` | `new \Cake\I18n\DateTime()` |
| `date('Y-m-d H:i:s')` | `new \Cake\I18n\DateTime()` |
| `extends AbstractMigration` | `extends BaseMigration` |
| `public function change()` in migration | `public function up()` + `public function down()` |
| `Query $query` in finder | `SelectQuery $query` |
| Raw SQL string in query | Use ORM query builder methods |
| `->order([` | `->orderBy([` |
| `$this->Auth->user()` | `$this->Authentication->getIdentity()` |
| `$this->loadModel('Foo')` | `$this->fetchTable('Foo')` |
| `TableRegistry::getTableLocator()` outside bootstrap | Inject via `fetchTable()` |
| `->get($id, ['contain' =>` | `->get($id, contain:` (CakePHP 5 named arg) |
| Hard delete (`->delete($entity)`) when `deleted_by` exists | Soft delete via `deleted_by` field |
| `protected function _execute()` in a Form | `protected function process()` (`_execute()` deprecated in 5.3) |
| `array` without generic shape in docblock | `array<string, mixed>` or typed shape |
| `style="..."` on any non-email template | Class in `webroot/css/site.css` or `admin.css` (see §14b) |
| `<link href="https://fonts.googleapis.com/...">` | Self-hosted on the project CDN (see §14c) |
| Debugging `Configure::read('EmailTransport.default')` returning null | Read `TransportFactory::getConfig('default')` — `bootstrap.php` consumed the key (§14d) |
| Admin layout missing `box-sizing: border-box` reset | Add the universal reset to admin.css (§14e) — fixes phantom 3px scrollbars |
| Paginator rendering when total pages = 1 | Wrap in `if ($this->Paginator->total() > 1)` (§14f) |
| Committing without running phpstan + cs-check | Run both, fix everything, then commit (§14a) |

---

## 14a. Pre-commit Hygiene — NEVER skip

Before proposing a `git commit`, ALWAYS run BOTH of these and fix what they find. Do not ask "should I run them?" — just run them. They are the bar.

```bash
docker compose exec app vendor/bin/phpstan analyse --level=8 src/
make composer CMD="run cs-check"
```

If `cs-check` reports auto-fixable violations, run `make composer CMD="run cs-fix"` and re-run BOTH commands (cs-fix can rearrange code in ways that surface new phpstan errors).

If phpstan complains about `Call to an undefined method object::someMethod()` after a `->first()` or `->get()` call, the fix is a docblock cast on the variable assignment:

```php
/** @var \App\Model\Entity\NewsArticle|null $article */
$article = $newsArticles->find('published')->where(...)->first();
```

If phpstan complains about a parent docblock with `\App\Controller\Response` as a return type, that's a bake-template bug — the type should be `\Cake\Http\Response`. Inheriting controllers will surface the error on their own `beforeFilter`/`beforeRender` even though the docblock lives in `AppController`.

---

## 14b. Templates — No NEW Inline Styles

**Don't add new `style="..."` attributes** in `.php` templates (except `templates/email/html/*` — HTML email clients require inline styles). And **migrate any inline styles you come across** while editing a file to `webroot/css/site.css` (public) or `webroot/css/admin.css` (admin), as touched-file cleanup.

This is the direction of travel, not a clean baseline: inline styles are often widespread in legacy templates. So the rule is incremental — every file you touch should come out with fewer inline styles than it went in with, and zero that you personally added.

Migration playbook:
1. Group repeated inline patterns and name them once: e.g. four checkboxes all carrying the same `style="text-transform:none;letter-spacing:0;..."` become one `.form-check-label` rule.
2. For one-offs, scope a class to the page or component (`.home-cta-lead`, `.news-empty-card`, `.location-tagline`) — not utility classes like `.mt-4`.
3. Keep contact-card patterns (role/name/phone/email blocks) in semantic classes (e.g. `.location-contact-list`, `.location-contact-role`, `.location-contact-link`) — these patterns tend to reappear across index/view/about templates, so name them once.

Check the files you touched (not the whole tree — the tree isn't clean yet):
```bash
grep -n 'style="' <files-you-edited>
# Expected: nothing you added; ideally fewer than before.
```

---

## 14c. External assets — must come from the project CDN

`fonts.googleapis.com`, `fonts.gstatic.com`, raw npm CDNs, unpkg, jsDelivr: NONE of these belong in production templates. Self-host everything except things that MUST be third-party (Google reCAPTCHA, Stripe.js, etc.).

Host self-served assets on the project's CDN/static bucket (e.g. `s3://<your-cdn-bucket>/templates/<site>/`, mirrored at `https://cdn.example.com/templates/<site>/`). Don't assume you lack AWS access — try first (§14g):

```bash
aws sts get-caller-identity         # confirm authenticated
aws s3 ls s3://<bucket>/<path>/     # confirm write target
```

### Bringing Google Fonts in-house

```bash
mkdir -p /tmp/fonts && cd /tmp/fonts
curl -s -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15" \
  "<google-fonts-css-url>" -o fonts.css
mkdir -p woff2 && grep -oE 'https://fonts.gstatic.com/[^)]*\.woff2' fonts.css | sort -u | \
  while read url; do curl -s "$url" -o "woff2/$(basename "$url")"; done
sed -E 's|https://fonts.gstatic.com/[^)]*/([^/)]+\.woff2)|woff2/\1|g' fonts.css > fonts-rewritten.css

aws s3 cp fonts-rewritten.css s3://<bucket>/templates/<site>/fonts/fonts.css \
  --content-type "text/css; charset=utf-8" --cache-control "public, max-age=31536000, immutable"
aws s3 sync woff2/ s3://<bucket>/templates/<site>/fonts/woff2/ \
  --content-type "font/woff2" --cache-control "public, max-age=31536000, immutable"
```

Then in each layout:
```html
<link rel="preconnect" href="https://cdn.example.com" crossorigin>
<link rel="stylesheet" href="https://cdn.example.com/templates/<site>/fonts/fonts.css">
```

Use the URL with the LARGEST superset of weights/styles when generating the CSS (typically the public layout's URL) — admin/error layouts use a subset, so one bundle covers all three.

---

## 14d. Don't chase phantom config bugs

A handful of CakePHP keys vanish from `Configure` after `bootstrap.php` runs because the framework moves them into a dedicated registry. The most common one:

```php
// config/bootstrap.php (default scaffold)
TransportFactory::setConfig(Configure::consume('EmailTransport'));
```

`Configure::consume()` reads and deletes. So `Configure::read('EmailTransport.default')` returns `null` at runtime — this is NOT a bug. To inspect the live transport config:

```php
\Cake\Mailer\TransportFactory::getConfig('default');
```

The same pattern applies to `DataSource` (consumed into `ConnectionManager`) and `Cache` (consumed into `Cache`). Read from the factory/manager, not `Configure`, for any post-bootstrap inspection.

---

## 14e. Admin layout CSS — required resets

Every `webroot/css/admin.css` (or any standalone admin stylesheet) MUST start with:

```css
*, *::before, *::after { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body { font-family: ...; background: ...; color: ...; }
```

Without `box-sizing: border-box`, a header with `height: 56px` AND `border-bottom: 3px` totals 59px — and `min-height: calc(100vh - 56px)` on the wrap below it produces a persistent 3px vertical scrollbar. Without `body { margin: 0 }` you'll see an 8px overflow from the browser default.

### Sticky sidebar pattern

When the admin layout is a flex row with a sidebar + main content, the sidebar should pin to the viewport, not scroll with the page:

```css
.admin-sidebar {
  /* layout */
  display: flex;
  flex-direction: column;
  /* stick under the header */
  position: sticky;
  top: <header-height>px;
  align-self: flex-start;          /* CRITICAL — stops flex from stretching the sidebar */
  height: calc(100vh - <header-height>px);
  overflow-y: auto;                /* internal scroll if the sidebar's own contents overflow */
}
```

`align-self: flex-start` is the bit people miss — without it, the flex container stretches the sidebar to match the main column's height, and `position: sticky` silently does nothing.

---

## 14f. Pagination — hide when there's only one page

Wrap the paginator block in a count check so empty/short result sets don't render dead Prev/Next buttons:

```php
<?php if ($this->Paginator->total() > 1): ?>
    <div class="paginator">
        <ul class="pagination">
            <?= $this->Paginator->first('« First') ?>
            <?= $this->Paginator->prev('‹ Prev') ?>
            <?= $this->Paginator->numbers() ?>
            <?= $this->Paginator->next('Next ›') ?>
            <?= $this->Paginator->last('Last »') ?>
        </ul>
    </div>
<?php endif; ?>
```

---

## 14g. Try the operation before declaring you can't

If a task requires AWS, GitHub, an API, or any external system — TRY first. Run `aws sts get-caller-identity`, `gh auth status`, `git remote -v`. Do not preemptively narrate "I can't push to the CDN without credentials" — the environment is often already set up with the tools and credentials needed, so confirm by running the command, not by assuming.

When you do hit a real permission boundary, name the exact command that failed and the exact error — never just "I don't have access."

---

## 15. reCAPTCHA v3 — server-side verification

Public-form controllers (Contact, Concern, etc.) verify a reCAPTCHA v3 token server-side. This helper tends to get copy-pasted between controllers — **when you add a third controller that needs it, extract it to a `RecaptchaTrait` or Component rather than pasting a fourth copy.**

Controller helper:
```php
private function verifyRecaptcha(string $token, string $secret): bool
{
    if ($token === '') {
        return false;
    }
    try {
        $response = (new \Cake\Http\Client())->post('https://www.google.com/recaptcha/api/siteverify', [
            'secret' => $secret,
            'response' => $token,
        ]);
        $result = $response->getJson();
    } catch (\Throwable $e) {
        return false;
    }

    return !empty($result['success']) && ($result['score'] ?? 0) >= 0.5;
}
```

In the action, gate the POST on it (keys live in `Configure::read('recaptcha')`):
```php
$keys = (array)Configure::read('recaptcha');
if (!empty($keys['secret_key']) && !$this->verifyRecaptcha((string)($data['g-recaptcha-response'] ?? ''), $keys['secret_key'])) {
    $this->Flash->error(__('We could not verify you are human. Please try again.'));
    // re-render without processing
}
```

**FormProtection note:** the JS sets `g-recaptcha-response` at submit time, so it must be unlocked in the template or FormProtection rejects the POST. Choices.js similarly injects a `search_terms` field at runtime — unlock it too:
```php
<?php $this->Form->unlockField('g-recaptcha-response'); ?>
<?php $this->Form->unlockField('search_terms'); // only if a Choices.js <select> is on the form ?>
```

---

## 16. Soft delete — centralize with `beforeFind`

§3 shows the manual `where([... 'deleted_by' => 0])` filter in each finder. The cleaner approach — the target for new tables — centralizes it in `beforeFind` so EVERY query is filtered automatically, with an opt-out flag:

```php
public function beforeFind(EventInterface $event, SelectQuery $query, ArrayObject $options, bool $primary): void
{
    if (empty($options['withDeleted'])) {
        $query->where([$this->aliasField('deleted_by') => 0]);
    }
}
```

Then deletes set the field instead of removing the row (the controller passes the authenticated user id):
```php
$entity->set('deleted_by', $userId);
$this->save($entity);
```

To include soft-deleted rows in an admin "show all" view: `->find('all', withDeleted: true)`. Pair this with a unique index gotcha — a `sort_order`/`slug` unique index will collide with soft-deleted rows; drop the DB-level unique constraint when adding soft delete to a table that has one.

---

## 17. Upload companion classes (ship with §8's behavior)

§8 covers the upload *behavior* config. In practice, always pair it with two `src/File/` helpers — when you wire the behavior, port these too:

**`src/File/Writer/AppWriter.php`** — extends `Josegonzalez\Upload\File\Writer\DefaultWriter`. Writes to a `.temp` path then atomically `move()`s into place (so a half-uploaded file is never served), stamps `ContentType` from the client media type, and — for PDFs — best-effort rasterizes page 1 to `thumb.jpg` via `pdftocairo`. Thumbnail failures are swallowed; they must never fail the upload. Referenced in the behavior config as `'writer' => \App\File\Writer\AppWriter::class`.

**`src/File/ImageOrientation.php`** — static `autorotate(ImageInterface $image, string $sourcePath): ImageInterface`. GD strips EXIF when generating derivatives, so phone photos come out sideways; this reads the source EXIF `Orientation` and rotates/flips the Imagine image to match before thumbnails are written. Call it at the top of the behavior's `transformer` callback:
```php
$image = (new \Imagine\Gd\Imagine())->open($data['tmp_name']);
$image = \App\File\ImageOrientation::autorotate($image, $data['tmp_name']);
```

Both guard their PHP extensions (`exif_read_data`, `exec`) with `function_exists` so they degrade gracefully where the binary/extension is absent.

---

## 18. TOTP two-factor authentication

Ship 2FA as two migrations plus a session gate. Port all three pieces together.

**Migrations:**
```php
// AddTotpToUsers
$this->table('users')
    ->addColumn('totp_secret', 'string', ['limit' => 64, 'null' => true, 'default' => null, 'after' => 'password'])
    ->addColumn('totp_enabled', 'boolean', ['null' => false, 'default' => false, 'after' => 'totp_secret'])
    ->update();

// CreateTotpRememberTokens — "remember this device" after a successful verify
$this->table('totp_remember_tokens', ['collation' => 'utf8mb4_unicode_ci'])
    ->addColumn('user_id', 'integer', ['signed' => false, 'null' => false])
    ->addColumn('token_hash', 'string', ['limit' => 64, 'null' => false])
    ->addColumn('expires_at', 'datetime', ['null' => false])
    ->addColumn('created', 'datetime', ['null' => false])
    ->addIndex(['user_id'])->addIndex(['token_hash'])->create();
```

**The gate** lives in `AppController::beforeFilter` for the `Admin` prefix: once a password login flags `_totp_required` in the session, every admin request redirects to `Users::verifyTwoFactor` until the code is entered — except the verify and logout actions themselves:
```php
if ($prefix === 'Admin' && $session->read('_totp_required') === true) {
    $controller = $this->getRequest()->getParam('controller');
    $action = $this->getRequest()->getParam('action');
    if (!($controller === 'Users' && in_array($action, ['verifyTwoFactor', 'logout'], true))) {
        return $this->redirect(['prefix' => 'Admin', 'controller' => 'Users', 'action' => 'verifyTwoFactor']);
    }
}
```
The `auth` layout (not `admin`) is used for `login` + `verifyTwoFactor` so the 2FA screen renders chrome-free.

---

## 19. Deploy — know what a push to `main` triggers

Before your first `git push`, inspect `.github/workflows/` (or the project's CI/CD config). **Many small-site setups deploy to production on every push to `main` with no manual gate.** If the project has such a workflow, expect a push to:

1. Stamp production secrets into `config/app_local.php` from CI secrets (`{{PLACEHOLDER}}` substitution or similar).
2. `rsync`/upload the tree to the server, then `composer install --no-dev` there.
3. **Run `bin/cake migrations migrate` on the production DB.**
4. Clear caches.

Implications for how you work:
- **New migrations may run against prod automatically on push.** A bad migration breaks production. Verify migrations locally (`make cake CMD="migrations migrate"`) before pushing.
- **Check whether tests gate the deploy** — deploy and CI workflows are often independent. Run the test suite, phpstan, and cs-check yourself before pushing to `main`.
- Watch the deploy after pushing: `gh run watch $(gh run list --workflow=main.yml --limit 1 --json databaseId -q '.[0].databaseId') --exit-status`.
- **Never commit real secrets** — production config should be stamped/managed outside the repo (locally `config/app_local.php` is often a symlink to a dev config).

---

## 20. Local environment gotchas (don't burn time on these)

- **Test DB access** — the test suite may fail to bootstrap with `Access denied for user '...' to database 'test_...'`. The dev DB user often lacks rights to the test database locally (CI may run the suite against sqlite instead). Don't chase it as a code bug — grant the user test-DB rights, or verify behavior by running the form/controller directly in the container.
- **New public actions redirect to the login** — when `AppController::beforeFilter` allow-lists a fixed set of action names via `addUnauthenticatedActions([...])`, a new public action with a name not in that list (e.g. a custom `thanks`) silently redirects visitors to the login page. Add the action name to the allow-list.
- **`Configure::consume()` deletes keys at bootstrap** — see §14d; inspect transports/datasources/cache via their factory (`TransportFactory::getConfig('default')`), not `Configure::read`.
- **Signed commits fail when the signing agent is locked** — e.g. 1Password SSH signing errors like `failed to fill whole buffer` / `agent returned an error` mean the signing app is locked, not that the commit is broken. Ask the user to unlock it, then retry; the staged changes are intact. Don't switch to `--no-gpg-sign` unless told to.
- **Tooling may live behind `make`** — bare `php`/`composer`/`bin/cake` on the host won't see the container (§0d). The `Xdebug: [Step Debug] Could not connect…` line printed by `bin/cake` is harmless noise.

---

## 21. Testing

Run the suite through the project's CLI wrapper (`make composer CMD="test"` in dockerized setups) or `vendor/bin/phpunit` directly.

### Fixtures — CakePHP 5 style

Fixture classes no longer define schema. Schema comes from migrations (or a schema dump) via the fixture strategy configured in `tests/bootstrap.php`; fixture classes only supply `$records`:

```php
<?php
declare(strict_types=1);

namespace App\Test\Fixture;

use Cake\TestSuite\Fixture\TestFixture;

class CustomersFixture extends TestFixture
{
    /**
     * @var array<int, array<string, mixed>>
     */
    public array $records = [
        ['id' => 1, 'name' => 'Acme', 'email' => 'acme@example.com', 'email_on_ticket' => false, 'deleted_by' => 0, 'created' => '2025-01-01 00:00:00', 'modified' => '2025-01-01 00:00:00'],
        ['id' => 2, 'name' => 'Gone Co', 'email' => 'gone@example.com', 'email_on_ticket' => false, 'deleted_by' => 1, 'created' => '2025-01-01 00:00:00', 'modified' => '2025-01-01 00:00:00'],
    ];
}
```

### Table tests

```php
<?php
declare(strict_types=1);

namespace App\Test\TestCase\Model\Table;

use Cake\TestSuite\TestCase;

class CustomersTableTest extends TestCase
{
    /**
     * @var array<string>
     */
    protected array $fixtures = ['app.Customers'];

    public function testFindActiveExcludesSoftDeleted(): void
    {
        $customers = $this->getTableLocator()->get('Customers');
        $this->assertSame(1, $customers->find('active')->count());
    }
}
```

### Controller tests — CSRF/FormProtection tokens

POSTs return 403/blackhole unless tokens are enabled — the #1 confusing test failure when CsrfProtectionMiddleware (§11) and FormProtection (§5) are wired up:

```php
<?php
declare(strict_types=1);

namespace App\Test\TestCase\Controller;

use Cake\TestSuite\IntegrationTestTrait;
use Cake\TestSuite\TestCase;

class CustomersControllerTest extends TestCase
{
    use IntegrationTestTrait;

    /**
     * @var array<string>
     */
    protected array $fixtures = ['app.Customers', 'app.Users'];

    public function testAdd(): void
    {
        $this->enableCsrfToken();
        $this->enableSecurityToken(); // needed when FormProtection is loaded
        $this->session(['Auth' => ['id' => 1, 'email' => 'admin@example.com']]); // authenticated identity
        $this->post('/customers/add', ['name' => 'New Co', 'email' => 'new@example.com']);
        $this->assertRedirect(['action' => 'index']);
    }
}
```

---

# cakephp.private.md — NEVER COMMIT / NEVER PUBLISH

Agency-specific values scrubbed from the public `cakephp.md` before publication.
This file is gitignored. Apply these on top of the public skill when working on
the csdurant fleet (most of this also lives in `~/.claude/commands/fleet-standard.md`).

## §0e / §4 / §16 — Adoption reference points

- "The newest codebase" that follows the 🆕 Emerging conventions (`FIELD_*`
  constants, `'*' => false`, `beforeFind` soft delete) is **caleraok.org**.
- The fleet running the TOTP 2FA pattern (§18): **clearview, csdurant, caleraok**.

## §14c — Real CDN / bucket values

- CDN bucket: `s3://computerservices/templates/<site>/`
- Mirrored at: `https://cdn.csdurant.com/templates/<site>/`
- Shared libs: `cdn.csdurant.com/lib/` (choices, trix, sortable, …); add missing
  libs to `s3://computerservices/lib/<name>/`.
- You DO have AWS access in the local shell (1Password shell plugin — run from
  the project directory, not scratchpad).

Layout links:
```html
<link rel="preconnect" href="https://cdn.csdurant.com" crossorigin>
<link rel="stylesheet" href="https://cdn.csdurant.com/templates/<site>/fonts/fonts.css">
```

## §19 — The fleet deploy pipeline (this IS how our sites ship)

`.github/workflows/main.yml` deploys to production on every push to `main`, no manual gate:

1. `cp config/app_local.production.php config/app_local.php` and `sed`-stamp
   `{{PLACEHOLDER}}` secrets (DB, SES, S3, reCAPTCHA, salt) from GitHub Actions secrets.
2. `rsync` the tree to the server (excluding `.env`, `vendor/`, `.git/`, `logs/`, `tmp/`),
   then `composer install --no-dev` there.
3. `bin/cake migrations migrate` runs on the production DB.
4. `bin/cake cache clear_all`.

`main.yml` (deploy) and `ci.yml` (test/lint) are independent — CI tests do NOT
gate the deploy. `config/app_local.php` is a symlink to `app_local.dev.php` locally.

## §20 — Fleet local environment specifics

- Dev DB (cakephp-docker-setup): host `db`, name `my_app`, user `my_app`,
  password `secret`. MySQL 8.4, PHP 8.3 FPM, MailCatcher on 1080.
- Test-DB failure signature: `Access denied for user 'my_app'@'%' to database
  'test_myapp'` — CI runs the suite against sqlite instead.
- Git commits are 1Password SSH-signed; `failed to fill whole buffer` means the
  1Password desktop app is locked.
- Admin login path fleet-wide: `/admin/users/login`.
- `op whoami` is a valid credential check here (1Password CLI is installed).
