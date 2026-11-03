<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SafeSpaceAssessmentSeeder extends Seeder
{
    public function run(): void
    {
        // Use an existing administrator account
        $adminId = DB::table('admins')
            ->orderBy('id')
            ->value('id');

        if (!$adminId) {
            throw new \RuntimeException(
                'No administrator account was found.'
            );
        }

        $options = [
            ['label' => 'Not at all', 'score' => 1],
            ['label' => 'A little', 'score' => 2],
            ['label' => 'Moderately', 'score' => 3],
            ['label' => 'Quite a lot', 'score' => 4],
            ['label' => 'Very much', 'score' => 5],
        ];

        $questions = [
            'How supported have you felt today?',
            'How manageable have your daily activities felt?',
            'How hopeful do you feel about the coming days?',
        ];

        foreach ($questions as $question) {
            $exists = DB::table('admins_questionnaire')
                ->where(
                    'title',
                    'Daily Wellbeing Check-In'
                )
                ->where('question', $question)
                ->exists();

            if ($exists) {
                continue;
            }

            DB::table('admins_questionnaire')->insert([
                'admin_id' => $adminId,
                'title' => 'Daily Wellbeing Check-In',
                'question' => $question,
                'options' => json_encode($options),
                'is_published' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
